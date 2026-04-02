require "json"
require "net/http"

module BlogSubscriptions
  class TurnstileVerifier
    VERIFY_URL = URI("https://challenges.cloudflare.com/turnstile/v0/siteverify")

    Result = Struct.new(:success, :message, :error_code, keyword_init: true) do
      def success?
        success
      end

      def configuration_error?
        error_code == :configuration
      end
    end

    def initialize(secret_key: ENV["CLOUDFLARE_TURNSTILE_SECRET_KEY"])
      @secret_key = secret_key
    end

    def verify(token:, remote_ip: nil)
      return invalid_result if token.blank?
      return configuration_error_result if secret_key.blank?

      request = Net::HTTP::Post.new(VERIFY_URL)
      request.set_form_data(
        "secret" => secret_key,
        "response" => token,
        "remoteip" => remote_ip,
      )

      response = Net::HTTP.start(VERIFY_URL.hostname, VERIFY_URL.port, use_ssl: true) do |http|
        http.request(request)
      end

      parsed_body = response.body.present? ? JSON.parse(response.body) : {}
      return success_result if response.is_a?(Net::HTTPSuccess) && parsed_body["success"]

      invalid_result
    rescue StandardError
      configuration_error_result
    end

    private
      attr_reader :secret_key

      def success_result
        Result.new(success: true, message: nil, error_code: nil)
      end

      def invalid_result
        Result.new(
          success: false,
          message: I18n.t("blog_subscriptions.create.verification_invalid"),
          error_code: :invalid_token,
        )
      end

      def configuration_error_result
        Result.new(
          success: false,
          message: I18n.t("blog_subscriptions.create.unavailable"),
          error_code: :configuration,
        )
      end
  end
end
