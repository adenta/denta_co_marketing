class InboundForwardingMailer < ApplicationMailer
  DEFAULT_RECIPIENT = "andrew.denta@gmail.com"

  def forward(inbound_email)
    @inbound_email = inbound_email
    @mail = inbound_email.mail

    attachments["original-message.eml"] = {
      mime_type: "message/rfc822",
      content: inbound_email.source
    }

    mail(
      to: ENV.fetch("INBOUND_FORWARDING_RECIPIENT", DEFAULT_RECIPIENT),
      subject: forwarded_subject,
      reply_to: @mail.from
    )
  end

  private
    def forwarded_subject
      original_subject = @mail.subject.presence || "(no subject)"
      "[Denta inbound] #{original_subject}"
    end
end
