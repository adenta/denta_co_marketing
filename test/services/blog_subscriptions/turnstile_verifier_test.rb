require "test_helper"

class BlogSubscriptions::TurnstileVerifierTest < ActiveSupport::TestCase
  test "verify returns success when cloudflare accepts the token" do
    verifier = BlogSubscriptions::TurnstileVerifier.new(secret_key: "secret")
    response = build_response(Net::HTTPOK, { success: true })

    with_stubbed_singleton_method(Net::HTTP, :start, fake_http_start(response)) do
      result = verifier.verify(token: "token", remote_ip: "127.0.0.1")

      assert result.success?
    end
  end

  test "verify returns configuration error when no secret is configured" do
    result = BlogSubscriptions::TurnstileVerifier.new(secret_key: nil).verify(token: "token")

    assert_not result.success?
    assert result.configuration_error?
  end

  private
    def fake_http_start(response)
      test_case = self

      lambda do |_host, _port, use_ssl:, &block|
        test_case.assert use_ssl

        block.call(
          Class.new do
            define_method(:initialize) { |http_response| @http_response = http_response }
            define_method(:request) { |_request| @http_response }
          end.new(response),
        )
      end
    end

    def build_response(response_class, payload)
      response = response_class.new("1.1", "200", "OK")
      response.instance_variable_set(:@read, true)
      response.instance_variable_set(:@body, JSON.dump(payload))
      response
    end
end
