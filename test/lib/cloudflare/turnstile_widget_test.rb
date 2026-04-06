require "test_helper"

class Cloudflare::TurnstileWidgetTest < ActiveSupport::TestCase
  test "ensure creates a widget when none exists" do
    client = Cloudflare::TurnstileWidget.new(api_token: "token", account_id: "account")

    responses = [
      build_response(
        success: true,
        result: [],
      ),
      build_response(
        success: true,
        result: {
          "sitekey" => "sitekey",
          "secret" => "secret",
          "domains" => Cloudflare::TurnstileWidget::DEFAULT_DOMAINS,
          "mode" => "managed",
        },
      ),
    ]

    with_stubbed_singleton_method(Net::HTTP, :start, fake_http_start(responses)) do
      result = client.ensure!(name: "signup", domains: Cloudflare::TurnstileWidget::DEFAULT_DOMAINS)

      assert_equal :created, result.action
      assert_equal "sitekey", result.sitekey
      assert_equal "secret", result.secret
      assert_equal Cloudflare::TurnstileWidget::DEFAULT_DOMAINS, result.domains
    end
  end

  test "ensure updates a matching widget" do
    client = Cloudflare::TurnstileWidget.new(api_token: "token", account_id: "account")

    responses = [
      build_response(
        success: true,
        result: [
          {
            "sitekey" => "sitekey",
            "name" => "signup",
            "domains" => [ "old.example.com" ],
            "mode" => "managed",
          },
        ],
      ),
      build_response(
        success: true,
        result: {
          "sitekey" => "sitekey",
          "domains" => Cloudflare::TurnstileWidget::DEFAULT_DOMAINS,
          "mode" => "managed",
        },
      ),
    ]

    with_stubbed_singleton_method(Net::HTTP, :start, fake_http_start(responses)) do
      result = client.ensure!(name: "signup", domains: Cloudflare::TurnstileWidget::DEFAULT_DOMAINS)

      assert_equal :updated, result.action
      assert_equal "sitekey", result.sitekey
      assert_nil result.secret
      assert_equal Cloudflare::TurnstileWidget::DEFAULT_DOMAINS, result.domains
    end
  end

  test "ensure resolves the account id when only one account is accessible" do
    client = Cloudflare::TurnstileWidget.new(api_token: "token", account_id: nil)

    responses = [
      build_response(
        success: true,
        result: [ { "id" => "resolved-account" } ],
      ),
      build_response(
        success: true,
        result: [],
      ),
      build_response(
        success: true,
        result: {
          "sitekey" => "sitekey",
          "secret" => "secret",
          "domains" => Cloudflare::TurnstileWidget::DEFAULT_DOMAINS,
          "mode" => "managed",
        },
      ),
    ]

    with_stubbed_singleton_method(Net::HTTP, :start, fake_http_start(responses)) do
      result = client.ensure!(name: "signup", domains: Cloudflare::TurnstileWidget::DEFAULT_DOMAINS)

      assert_equal :created, result.action
      assert_equal "sitekey", result.sitekey
    end
  end

  private
    def fake_http_start(responses)
      queue = responses.dup
      test_case = self

      lambda do |_host, _port, use_ssl:, &block|
        test_case.assert use_ssl
        response = queue.shift or raise "No queued response"

        block.call(
          Class.new do
            define_method(:initialize) { |http_response| @http_response = http_response }
            define_method(:request) { |_request| @http_response }
          end.new(response),
        )
      end
    end

    def build_response(payload)
      response = Net::HTTPOK.new("1.1", "200", "OK")
      response.instance_variable_set(:@read, true)
      response.instance_variable_set(:@body, JSON.dump(payload))
      response
    end
end
