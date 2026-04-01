namespace :postarity do
  namespace :postmark do
    namespace :inbound do
      # Status note:
      # - These tasks have not been used in production yet.
      # - They exist as a future operational path if we decide to enable and tune
      #   Postmark inbound blocking later.
      # - Treat them as prepared setup, not an active, proven workflow.
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

      namespace :blocking do
        desc "Show the Postmark inbound blocking settings (POSTMARK_INBOUND_SPAM_THRESHOLD, POSTMARK_INBOUND_BLOCK_RULES)"
        task show: :environment do
          config = Postarity::PostmarkInbound.new

          puts "Spam threshold: #{config.spam_threshold}"
          if config.block_rules.any?
            puts "Configured block rules:"
            config.block_rules.each do |rule|
              puts "  - #{rule}"
            end
          else
            puts "Configured block rules: none"
          end
        end

        desc "Apply the Postmark inbound spam threshold and add any configured sender/domain block rules"
        task apply: :environment do
          config = Postarity::PostmarkInbound.new
          result = config.apply_blocking!
          server = result.fetch("Server")
          added_rules = result.fetch("AddedRules")

          puts "Applied Postmark inbound blocking."
          puts "Spam threshold: #{server["InboundSpamThreshold"]}"

          if config.block_rules.any?
            puts "Configured block rules: #{config.block_rules.join(", ")}"
            puts "Added block rules: #{added_rules.any? ? added_rules.join(", ") : "none"}"
          else
            puts "Configured block rules: none"
          end
        end
      end
    end
  end
end
