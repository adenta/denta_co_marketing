# frozen_string_literal: true

require "time"
require_relative "lib/setup"

TmpPostmarkMail::Env.load!

unless ENV["POSTMARK_SERVER_TOKEN"].to_s.strip.empty?
  postmark = TmpPostmarkMail::PostmarkClient.new(
    account_token: ENV.fetch("POSTMARK_ACCOUNT_TOKEN", ENV.fetch("POSTMARK_API_TOKEN")),
    server_token: ENV.fetch("POSTMARK_SERVER_TOKEN")
  )
  server = postmark.server
  snapshot = TmpPostmarkMail::Snapshot.write(
    "04_postmark_server.json",
    {
      checked_at: Time.now.utc.iso8601,
      server:
    }
  )

  puts "Postmark server token works for server #{server["ID"]}: #{server["Name"]}"
  puts "Snapshot saved to #{snapshot}"
else
  warn "POSTMARK_SERVER_TOKEN is not set, so server-level probing was skipped."
  warn "That is expected for now if you only want to iterate on mail.denta.co DNS first."
end
