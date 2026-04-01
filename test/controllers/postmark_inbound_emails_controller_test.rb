require "test_helper"

class PostmarkInboundEmailsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @previous_ingress = ActionMailbox.ingress
    @previous_password = ENV["RAILS_INBOUND_EMAIL_PASSWORD"]

    ActionMailbox.ingress = :postmark
    ENV["RAILS_INBOUND_EMAIL_PASSWORD"] = "test-ingress-password"
    ActionMailer::Base.deliveries.clear
  end

  teardown do
    ActionMailbox.ingress = @previous_ingress
    ENV["RAILS_INBOUND_EMAIL_PASSWORD"] = @previous_password
    clear_enqueued_jobs
    clear_performed_jobs
  end

  test "ingests Postmark payloads and forwards them through the catch-all mailbox" do
    raw_email = <<~EMAIL
      From: Patient <patient@example.com>
      To: support@mail.denta.co
      Subject: New inbound lead
      Message-ID: <lead-123@example.com>
      Date: Tue, 31 Mar 2026 10:00:00 -0400

      Hello from Postmark.
    EMAIL

    perform_enqueued_jobs do
      post rails_postmark_inbound_emails_path,
        params: {
          RawEmail: raw_email,
          OriginalRecipient: "support@mail.denta.co"
        },
        headers: {
          "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials(
            "actionmailbox",
            "test-ingress-password"
          )
        }
    end

    assert_response :no_content
    assert_equal 1, ActionMailbox::InboundEmail.count

    email = ActionMailer::Base.deliveries.last
    assert_equal [ ENV.fetch("INBOUND_FORWARDING_RECIPIENT", InboundForwardingMailer::DEFAULT_RECIPIENT) ], email.to
    assert_equal "[Denta inbound] New inbound lead", email.subject
    assert_match "Hello from Postmark.", email.body.encoded
  end
end
