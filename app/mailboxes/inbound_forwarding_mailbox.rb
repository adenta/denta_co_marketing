class InboundForwardingMailbox < ApplicationMailbox
  def process
    InboundForwardingMailer.forward(inbound_email).deliver_now
  end
end
