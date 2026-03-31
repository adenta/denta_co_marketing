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
domains = postmark.domains

snapshot = TmpPostmarkMail::Snapshot.write(
  "01_verify_tokens.json",
  {
    checked_at: Time.now.utc.iso8601,
    zone: {
      id: zone["id"],
      name: zone["name"],
      account_id: zone.dig("account", "id"),
      permissions: zone["permissions"]
    },
    postmark_domains: domains
  }
)

puts "Cloudflare zone access OK for #{zone["name"]} (#{zone["id"]})"
puts "Cloudflare permissions: #{Array(zone["permissions"]).join(", ")}"
puts "Postmark account token OK. Domains visible: #{domains.map { |domain| domain["Name"] }.join(', ')}"
puts "Snapshot saved to #{snapshot}"
