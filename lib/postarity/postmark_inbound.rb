require "json"
require "net/http"
require "uri"
require "yaml"

module Postarity
  # Operational helper for the app's existing Postmark + Action Mailbox setup.
  #
  # Status note:
  # - The inbound blocking helpers in this file have not been used in production
  #   yet.
  # - They are intentionally kept here as a future operational path in case we
  #   decide Postmark-side spam blocking is needed later.
  # - Treat this as prepared infrastructure, not a proven active workflow.
  #
  # Why this lives under `Postarity`:
  # - The `postarity:*` tasks are intended as lightweight operational helpers and
  #   future-reference tooling, not as part of the user-facing application flow.
  # - This class is used by those tasks to print or apply the Postmark inbound
  #   server configuration in a repeatable way.
  #
  # What this file does:
  # - Builds the Action Mailbox ingress URL that Postmark should call.
  # - Infers sensible defaults from Rails config and `config/deploy.yml`.
  # - Optionally pushes the inbound webhook settings to Postmark's server API.
  #
  # What this file does *not* do:
  # - It does not install Action Mailbox.
  # - It does not define mailbox routing or forwarding behavior.
  # - It does not need to run during normal inbound email processing.
  #
  # In other words, the Rails-side inbound handling is configured elsewhere.
  # This class exists so we can inspect or re-apply the matching Postmark server
  # settings later without reconstructing the webhook URL by hand.
  class PostmarkInbound
    API_URL = URI("https://api.postmarkapp.com/server")
    INBOUND_RULES_API_URL = URI("https://api.postmarkapp.com/triggers/inboundrules")
    INGRESS_PATH = "/rails/action_mailbox/postmark/inbound_emails"
    DEFAULT_SPAM_THRESHOLD = 5
    INBOUND_RULES_PAGE_SIZE = 500
    USERNAME = "actionmailbox"

    def initialize(host: nil, scheme: nil, password: nil, inbound_domain: nil, server_token: nil, spam_threshold: nil, block_rules: nil)
      default_url_options = Rails.application.routes.default_url_options.symbolize_keys

      @host = host || ENV["POSTMARK_INBOUND_HOST"] || inferred_application_host || default_url_options.fetch(:host)
      @scheme = scheme || ENV["POSTMARK_INBOUND_SCHEME"] || inferred_application_scheme || default_url_options.fetch(:protocol, "https")
      @password = password || ENV["RAILS_INBOUND_EMAIL_PASSWORD"]
      @inbound_domain = inbound_domain || ENV["POSTMARK_INBOUND_DOMAIN"] || inferred_inbound_domain
      @server_token = server_token || ENV["POSTMARK_SERVER_TOKEN"]
      @spam_threshold = normalize_spam_threshold(spam_threshold || ENV["POSTMARK_INBOUND_SPAM_THRESHOLD"])
      @block_rules = normalize_block_rules(block_rules || ENV["POSTMARK_INBOUND_BLOCK_RULES"])
    end

    attr_reader :block_rules, :host, :inbound_domain, :password, :scheme, :server_token

    # The authenticated ingress URL that should be configured as Postmark's
    # inbound webhook target for this app.
    def webhook_url
      raise ArgumentError, "RAILS_INBOUND_EMAIL_PASSWORD is required" if password.blank?

      uri = URI.parse("#{scheme}://#{host}")
      uri.user = USERNAME
      uri.password = password
      uri.path = INGRESS_PATH
      uri.to_s
    end

    def redacted_webhook_url
      webhook_url.sub(":#{password}@", ":[FILTERED]@")
    end

    # Payload shape expected by Postmark's server update API for inbound mail.
    def payload
      {
        "InboundHookUrl" => webhook_url,
        "RawEmailEnabled" => true,
        "InboundDomain" => inbound_domain
      }.compact
    end

    def spam_threshold
      @spam_threshold || DEFAULT_SPAM_THRESHOLD
    end

    # Payload shape expected by Postmark's server update API for inbound
    # blocking. This only manages the server-wide spam threshold.
    def blocking_payload
      {
        "InboundSpamThreshold" => spam_threshold
      }
    end

    # Applies the current inbound settings to the Postmark server identified by
    # POSTMARK_SERVER_TOKEN. This is an operational action, not part of request
    # handling, so callers should invoke it intentionally via the rake task.
    def apply!
      update_server!(payload)
    end

    # Applies the spam threshold and creates any configured sender/domain block
    # rules that do not already exist on the server.
    def apply_blocking!
      server = update_server!(blocking_payload)
      existing_rules = inbound_rules
      added_rules = block_rules.filter_map do |rule|
        next if existing_rules.include?(rule)

        create_inbound_rule!(rule).fetch("Rule")
      end

      {
        "Server" => server,
        "AddedRules" => added_rules,
        "ExistingRules" => existing_rules
      }
    end

    def inbound_rules
      raise ArgumentError, "POSTMARK_SERVER_TOKEN is required" if server_token.blank?

      offset = 0
      rules = []

      loop do
        uri = INBOUND_RULES_API_URL.dup
        uri.query = URI.encode_www_form(count: INBOUND_RULES_PAGE_SIZE, offset: offset)
        response = request_json(Net::HTTP::Get, uri)
        page_rules = Array(response["InboundRules"]).filter_map { |rule| rule["Rule"] }.map(&:strip)
        rules.concat(page_rules)

        break if page_rules.size < INBOUND_RULES_PAGE_SIZE

        offset += INBOUND_RULES_PAGE_SIZE
      end

      rules.uniq.sort
    end

    private
      def update_server!(attributes)
        raise ArgumentError, "POSTMARK_SERVER_TOKEN is required" if server_token.blank?

        request_json(Net::HTTP::Put, API_URL, attributes)
      end

      def create_inbound_rule!(rule)
        raise ArgumentError, "POSTMARK_SERVER_TOKEN is required" if server_token.blank?

        request_json(Net::HTTP::Post, INBOUND_RULES_API_URL, { "Rule" => rule })
      end

      def request_json(request_class, uri, body = nil)
        request = request_class.new(uri)
        request["Accept"] = "application/json"
        request["X-Postmark-Server-Token"] = server_token

        if body
          request["Content-Type"] = "application/json"
          request.body = JSON.dump(body)
        end

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == "https") do |http|
          http.request(request)
        end

        parsed_body = response.body.present? ? JSON.parse(response.body) : {}
        return parsed_body if response.is_a?(Net::HTTPSuccess)

        message = parsed_body["Message"] || parsed_body.inspect
        raise "Postmark update failed (HTTP #{response.code}): #{message}"
      end

      def normalize_spam_threshold(value)
        return if value.blank?

        Integer(value)
      end

      def normalize_block_rules(value)
        Array(value)
          .flat_map { |entry| entry.to_s.split(/[\n,;]/) }
          .map(&:strip)
          .reject(&:blank?)
          .uniq
          .sort
      end

      # We derive the inbound domain from the app's default sender so the
      # Postmark side stays aligned with the configured mail domain.
      def inferred_inbound_domain
        from_address = ApplicationMailer.default_params[:from].to_s
        from_address.split("@", 2).last.presence
      end

      # `config/deploy.yml` includes both the app host (`denta.co`) and the mail
      # subdomain (`mail.denta.co`). The ingress webhook host should point at the
      # app, not the inbound mail domain, so we prefer the non-mail host here.
      def inferred_application_host
        Array(deploy_config.dig("proxy", "hosts")).find { |value| !value.start_with?("mail.") }
      end

      def inferred_application_scheme
        deploy_config.dig("proxy", "ssl") ? "https" : nil
      end

      def deploy_config
        @deploy_config ||=
          begin
            YAML.load_file(Rails.root.join("config", "deploy.yml"))
          rescue Errno::ENOENT, Psych::SyntaxError
            {}
          end
      end
  end
end
