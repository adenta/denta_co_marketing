namespace :postarity do
  namespace :postmark do
    namespace :inbound do
      desc "Show the Postmark inbound webhook settings for Action Mailbox"
      task show: :environment do
        config = Postarity::PostmarkInbound.new

        puts "Webhook URL: #{config.webhook_url}"
        puts "Inbound domain: #{config.inbound_domain}"
        puts "Raw email enabled: true"
        puts "Forwarding recipient: #{ENV.fetch("INBOUND_FORWARDING_RECIPIENT", InboundForwardingMailer::DEFAULT_RECIPIENT)}"
      end

      desc "Apply the Postmark inbound webhook settings to the configured server"
      task apply: :environment do
        config = Postarity::PostmarkInbound.new
        server = config.apply!

        puts "Applied Postmark inbound settings."
        puts "Inbound domain: #{server["InboundDomain"]}"
        puts "Inbound webhook: #{config.redacted_webhook_url}"
        puts "Raw email enabled: #{server["RawEmailEnabled"]}"
      end
    end
  end
end
