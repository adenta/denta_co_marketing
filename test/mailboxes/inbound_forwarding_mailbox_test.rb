require "test_helper"

class InboundForwardingMailboxTest < ActionMailbox::TestCase
  include ActionMailer::TestHelper

  test "routes catch-all inbound messages to the forwarding recipient" do
    assert_emails 1 do
      receive_inbound_email_from_mail(
        to: "support@mail.denta.co",
        from: "Patient <patient@example.com>",
        subject: "Question",
        body: "Hello from inbound mail."
      )
    end

    email = ActionMailer::Base.deliveries.last

    assert_equal [ ENV.fetch("INBOUND_FORWARDING_RECIPIENT", InboundForwardingMailer::DEFAULT_RECIPIENT) ], email.to
    assert_equal [ "patient@example.com" ], email.reply_to
    assert_equal "[Denta inbound] Question", email.subject
    assert_match "Hello from inbound mail.", email.text_part ? email.text_part.body.to_s : email.body.to_s
    assert email.attachments.any? { |attachment| attachment.filename.to_s == "original-message.eml" }
  end
end
