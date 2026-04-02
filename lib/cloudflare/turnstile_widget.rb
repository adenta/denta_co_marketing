require "json"
require "net/http"

module Cloudflare
  class TurnstileWidget
    API_BASE_URL = "https://api.cloudflare.com/client/v4".freeze
    DEFAULT_NAME = "denta_co_marketing blog signup".freeze
    DEFAULT_DOMAINS = %w[denta.co mail.denta.co].freeze

    Result = Struct.new(:action, :sitekey, :secret, :domains, :mode, keyword_init: true)

    def initialize(api_token: ENV["CLOUDFLARE_TOKEN"], account_id: ENV["CLOUDFLARE_ACCOUNT_ID"])
      @api_token = api_token
      @account_id = account_id
    end

    def ensure!(name: DEFAULT_NAME, domains: DEFAULT_DOMAINS, mode: "managed")
      normalized_domains = normalize_domains(domains)
      widget = widgets.find { |candidate| candidate.fetch("name") == name }

      if widget
        update_widget(widget.fetch("sitekey"), name:, domains: normalized_domains, mode:)
      else
        create_widget(name:, domains: normalized_domains, mode:)
      end
    end

    private
      attr_reader :api_token

      def account_id
        @account_id ||= begin
          accounts = request(:get, "/accounts").fetch("result")
          raise "CLOUDFLARE_ACCOUNT_ID is required when multiple Cloudflare accounts are accessible" unless accounts.one?

          accounts.first.fetch("id")
        end
      end

      def widgets
        request(:get, "/accounts/#{account_id}/challenges/widgets?per_page=100").fetch("result")
      end

      def create_widget(name:, domains:, mode:)
        payload = request(
          :post,
          "/accounts/#{account_id}/challenges/widgets",
          {
            domains:,
            mode:,
            name:,
          },
        ).fetch("result")

        Result.new(
          action: :created,
          sitekey: payload.fetch("sitekey"),
          secret: payload.fetch("secret"),
          domains: payload.fetch("domains"),
          mode: payload.fetch("mode"),
        )
      end

      def update_widget(sitekey, name:, domains:, mode:)
        payload = request(
          :put,
          "/accounts/#{account_id}/challenges/widgets/#{sitekey}",
          {
            domains:,
            mode:,
            name:,
          },
        ).fetch("result")

        Result.new(
          action: :updated,
          sitekey: payload.fetch("sitekey"),
          secret: payload["secret"],
          domains: payload.fetch("domains"),
          mode: payload.fetch("mode"),
        )
      end

      def normalize_domains(domains)
        Array(domains).flat_map { |entry| entry.to_s.split(",") }.map(&:strip).reject(&:blank?).uniq
      end

      def request(method, path, payload = nil)
        raise "CLOUDFLARE_TOKEN is required" if api_token.blank?

        uri = URI("#{API_BASE_URL}#{path}")
        request = request_class_for(method).new(uri)
        request["Authorization"] = "Bearer #{api_token}"
        request["Content-Type"] = "application/json"
        request.body = JSON.dump(payload) if payload

        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request)
        end

        parsed_body = response.body.present? ? JSON.parse(response.body) : {}
        return parsed_body if response.is_a?(Net::HTTPSuccess) && parsed_body["success"]

        raise build_error_message(parsed_body, response)
      end

      def request_class_for(method)
        {
          get: Net::HTTP::Get,
          post: Net::HTTP::Post,
          put: Net::HTTP::Put,
        }.fetch(method)
      end

      def build_error_message(parsed_body, response)
        messages = Array(parsed_body["errors"]).map { |error| error["message"] }.compact
        messages = [ response.message ] if messages.empty?
        "Cloudflare Turnstile API request failed: #{messages.join(', ')}"
      end
  end
end
