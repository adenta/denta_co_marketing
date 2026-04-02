# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

vite_origin = ViteRuby.config.origin
vite_websocket_origin = "#{ViteRuby.config.protocol == "https" ? "wss" : "ws"}://#{ViteRuby.config.host_with_port}"

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.base_uri :self
    policy.connect_src :self
    policy.font_src :self, :data
    policy.form_action :self
    policy.frame_ancestors :none
    policy.frame_src :self, "https://www.youtube.com", "https://www.youtube-nocookie.com"
    policy.img_src :self, :https, :data
    policy.object_src :none
    policy.report_uri "/csp-violation-reports"
    policy.script_src :self
    policy.style_src :self

    if Rails.env.development?
      policy.connect_src *policy.connect_src, vite_origin, vite_websocket_origin
      policy.script_src *policy.script_src, :unsafe_eval, vite_origin
      policy.style_src *policy.style_src, :unsafe_inline
    end

    policy.script_src *policy.script_src, :blob if Rails.env.test?
  end

  # Cookie-store sessions may not have an id for anonymous requests, so fall back
  # to a generated per-request nonce to keep Vite's inline React refresh preamble working.
  config.content_security_policy_nonce_generator = lambda do |request|
    request.session.id.to_s.presence || SecureRandom.base64(16)
  end
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end
