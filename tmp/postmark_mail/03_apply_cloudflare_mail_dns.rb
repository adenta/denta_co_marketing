# frozen_string_literal: true

require "time"
require_relative "lib/setup"

TmpPostmarkMail::Env.load!

config = TmpPostmarkMail::Config.new
cloudflare = TmpPostmarkMail::CloudflareClient.new(token: ENV.fetch("CLOUDFLARE_TOKEN"))
postmark = TmpPostmarkMail::PostmarkClient.new(
  account_token: ENV.fetch("POSTMARK_ACCOUNT_TOKEN", ENV.fetch("POSTMARK_API_TOKEN"))
)

zone = cloudflare.zone(config.zone_name)
domain = postmark.ensure_domain(config.mail_domain)
plan = TmpPostmarkMail::DnsPlan.new(domain_details: domain, config:)

applied = plan.records.map do |record|
  result = cloudflare.upsert_record(zone_id: zone.fetch("id"), record:)
  {
    desired: record,
    cloudflare_record_id: result["id"],
    cloudflare_name: result["name"],
    cloudflare_type: result["type"],
    content: result["content"]
  }
end

snapshot = TmpPostmarkMail::Snapshot.write(
  "03_cloudflare_dns.json",
  {
    checked_at: Time.now.utc.iso8601,
    zone: zone.slice("id", "name"),
    mail_domain: config.mail_domain,
    records: applied
  }
)

puts "Applied #{applied.length} Cloudflare DNS records for #{config.mail_domain}"
plan.records.each do |record|
  puts "- #{record[:type]} #{record[:name]} -> #{record[:content]}"
end
puts "Snapshot saved to #{snapshot}"
