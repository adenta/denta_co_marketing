# frozen_string_literal: true

root = File.expand_path(__dir__)

load File.join(root, "01_verify_tokens.rb")
load File.join(root, "02_ensure_postmark_domain.rb")
load File.join(root, "03_apply_cloudflare_mail_dns.rb")
load File.join(root, "04_probe_postmark_server.rb")
