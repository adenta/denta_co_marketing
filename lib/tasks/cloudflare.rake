namespace :cloudflare do
  namespace :turnstile do
    desc "Create or update the blog signup Turnstile widget"
    task ensure: :environment do
      name = ENV.fetch("TURNSTILE_WIDGET_NAME", Cloudflare::TurnstileWidget::DEFAULT_NAME)
      domains = ENV.fetch("TURNSTILE_DOMAINS", Cloudflare::TurnstileWidget::DEFAULT_DOMAINS.join(","))

      result = Cloudflare::TurnstileWidget.new.ensure!(name:, domains:)

      puts "Turnstile widget #{result.action}: #{name}"
      puts "Domains: #{result.domains.join(', ')}"
      puts "Mode: #{result.mode}"
      puts "Sitekey: #{result.sitekey}"
      puts "Secret: #{result.secret}" if result.secret.present?
    end
  end
end
