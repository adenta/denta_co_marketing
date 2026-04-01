require "test_helper"

class Postarity::PostmarkInboundTest < ActiveSupport::TestCase
  test "builds the inbound webhook URL from the Rails host and ingress password" do
    config = Postarity::PostmarkInbound.new(password: "super-secret")

    assert_equal(
      "https://actionmailbox:super-secret@denta.co/rails/action_mailbox/postmark/inbound_emails",
      config.webhook_url
    )
    assert_equal "mail.denta.co", config.inbound_domain
    assert_equal true, config.payload["RawEmailEnabled"]
  end

  test "redacts the password when reporting the webhook URL" do
    config = Postarity::PostmarkInbound.new(password: "super-secret")

    assert_equal(
      "https://actionmailbox:[FILTERED]@denta.co/rails/action_mailbox/postmark/inbound_emails",
      config.redacted_webhook_url
    )
  end

  test "normalizes blocking settings from initializer inputs" do
    config = Postarity::PostmarkInbound.new(
      password: "super-secret",
      spam_threshold: "7",
      block_rules: "spam@example.com,\nexample.net; spam@example.com"
    )

    assert_equal 7, config.spam_threshold
    assert_equal [ "example.net", "spam@example.com" ], config.block_rules
    assert_equal({ "InboundSpamThreshold" => 7 }, config.blocking_payload)
  end

  test "uses a conservative default spam threshold when none is configured" do
    config = Postarity::PostmarkInbound.new(password: "super-secret")

    assert_equal 5, config.spam_threshold
    assert_equal({ "InboundSpamThreshold" => 5 }, config.blocking_payload)
  end

  test "apply_blocking updates the spam threshold and only adds missing rules" do
    config = Postarity::PostmarkInbound.new(
      password: "super-secret",
      server_token: "server-token",
      spam_threshold: 6,
      block_rules: [ "existing.example", "spam@example.com" ]
    )

    created_rules = []
    config.define_singleton_method(:update_server!) { |_attributes| { "InboundSpamThreshold" => 6 } }
    config.define_singleton_method(:inbound_rules) { [ "existing.example" ] }
    config.define_singleton_method(:create_inbound_rule!) do |rule|
      created_rules << rule
      { "Rule" => rule }
    end

    result = config.apply_blocking!

    assert_equal [ "spam@example.com" ], created_rules
    assert_equal [ "existing.example" ], result["ExistingRules"]
    assert_equal [ "spam@example.com" ], result["AddedRules"]
    assert_equal 6, result["Server"]["InboundSpamThreshold"]
  end
end
