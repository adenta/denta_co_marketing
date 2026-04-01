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
end
