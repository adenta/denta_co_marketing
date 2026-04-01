require "json"
require "net/http"
require "uri"
require "yaml"

module Postarity
  # Operational helper for the app's existing Postmark + Action Mailbox setup.
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
    INGRESS_PATH = "/rails/action_mailbox/postmark/inbound_emails"
    USERNAME = "actionmailbox"

    def initialize(host: nil, scheme: nil, password: nil, inbound_domain: nil, server_token: nil)
      default_url_options = Rails.application.routes.default_url_options.symbolize_keys

      @host = host || ENV["POSTMARK_INBOUND_HOST"] || inferred_application_host || default_url_options.fetch(:host)
      @scheme = scheme || ENV["POSTMARK_INBOUND_SCHEME"] || inferred_application_scheme || default_url_options.fetch(:protocol, "https")
      @password = password || ENV["RAILS_INBOUND_EMAIL_PASSWORD"]
      @inbound_domain = inbound_domain || ENV["POSTMARK_INBOUND_DOMAIN"] || inferred_inbound_domain
      @server_token = server_token || ENV["POSTMARK_SERVER_TOKEN"]
    end

    attr_reader :host, :inbound_domain, :password, :scheme, :server_token

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

    # Applies the current inbound settings to the Postmark server identified by
    # POSTMARK_SERVER_TOKEN. This is an operational action, not part of request
    # handling, so callers should invoke it intentionally via the rake task.
    def apply!
      raise ArgumentError, "POSTMARK_SERVER_TOKEN is required" if server_token.blank?

      request = Net::HTTP::Put.new(API_URL)
      request["Accept"] = "application/json"
      request["Content-Type"] = "application/json"
      request["X-Postmark-Server-Token"] = server_token
      request.body = JSON.dump(payload)

      response = Net::HTTP.start(API_URL.hostname, API_URL.port, use_ssl: true) do |http|
        http.request(request)
      end

      parsed_body = response.body.present? ? JSON.parse(response.body) : {}
      return parsed_body if response.is_a?(Net::HTTPSuccess)

      message = parsed_body["Message"] || parsed_body.inspect
      raise "Postmark update failed (HTTP #{response.code}): #{message}"
    end

    private
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
