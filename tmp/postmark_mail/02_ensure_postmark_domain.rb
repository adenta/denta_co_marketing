# frozen_string_literal: true

require "time"
require_relative "lib/setup"

TmpPostmarkMail::Env.load!

config = TmpPostmarkMail::Config.new
postmark = TmpPostmarkMail::PostmarkClient.new(
  account_token: ENV.fetch("POSTMARK_ACCOUNT_TOKEN", ENV.fetch("POSTMARK_API_TOKEN"))
)
domain = postmark.ensure_domain(config.mail_domain)

snapshot = TmpPostmarkMail::Snapshot.write(
  "02_postmark_domain.json",
  {
    checked_at: Time.now.utc.iso8601,
    mail_domain: config.mail_domain,
    return_path_domain: config.return_path_domain,
    domain:
  }
)

puts "Postmark domain ready: #{domain["Name"]} (ID #{domain["ID"]})"
puts "SPF host: #{domain["SPFHost"]}"
puts "DKIM host: #{domain["DKIMPendingHost"] || domain["DKIMHost"]}"
puts "Return path: #{domain["ReturnPathDomain"]} -> #{domain["ReturnPathDomainCNAMEValue"]}"
puts "Snapshot saved to #{snapshot}"
