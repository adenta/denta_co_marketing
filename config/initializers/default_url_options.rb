# frozen_string_literal: true

hosts = {
  development: "localhost:3000",
  test: "example.com",
  production: "denta.co"
}.freeze

protocols = {
  development: "http",
  test: "http",
  production: "https"
}.freeze

Rails.application.config.to_prepare do
  env = Rails.env.to_sym
  route_options = {
    host: hosts.fetch(env),
    protocol: protocols.fetch(env)
  }

  Rails.application.routes.default_url_options = route_options.dup
  Rails.application.config.action_mailer.default_url_options = route_options.dup
  ActiveStorage::Current.url_options = route_options.dup if defined?(ActiveStorage::Current)
end
