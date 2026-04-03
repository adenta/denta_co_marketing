require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "index renders the splash page for signed out visitors" do
    get root_path

    assert_response :success
    assert_includes @response.body, "home/index"
    assert_includes @response.body, "Founder and engineer working on AI systems that reduce operational drag."
    assert_includes @response.body, "<title>Andrew Denta</title>"
    assert_includes @response.body, '<meta name="description" content="A personal site and blog about useful AI, software, systems, and the operational friction that shapes real work.">'
    assert_includes @response.body, "navigation/SiteNav"
    assert_includes @response.body, "denta-theme"
    refute_includes @response.body, "navigation/Navbar"
    assert_includes @response.body, "&quot;developerSignInEnabled&quot;:true"
    refute_includes @response.body, "available_agents"
    refute_includes @response.body, "&quot;sign_in_path&quot;"
    refute_includes @response.body, "&quot;sign_up_path&quot;"
    refute_includes @response.body, "Mangrove Technology Engagements"
  end

  test "index renders the splash page for signed in users" do
    sign_in_as(users(:one))

    get root_path

    assert_response :success
    assert_includes @response.body, "home/index"
    assert_includes @response.body, "navigation/SiteNav"
    refute_includes @response.body, "navigation/Navbar"
    refute_includes @response.body, users(:one).email_address
    refute_includes @response.body, "available_agents"
  end

  test "index renders the production splash page" do
    get root_path

    assert_response :success
    assert_includes @response.body, "home/index"
    refute_includes @response.body, "home/splash1"
    assert_includes @response.body, "&quot;content&quot;:"
    assert_includes @response.body, "&quot;recent_posts&quot;:"
  end

  test "index omits auth controls for signed out visitors when developer sign in is disabled" do
    original_env_method = Rails.method(:env)
    Rails.define_singleton_method(:env) { ActiveSupport::StringInquirer.new("production") }

    get root_path

    assert_response :success
    assert_includes @response.body, "navigation/SiteNav"
    assert_includes @response.body, "&quot;developerSignInEnabled&quot;:false"
  ensure
    Rails.define_singleton_method(:env, original_env_method)
  end

  test "index includes the content security policy header" do
    get root_path

    assert_response :success

    policy = response.headers["Content-Security-Policy"]

    assert_includes policy, "default-src 'self'"
    assert_includes policy, "base-uri 'self'"
    assert_includes policy, "connect-src 'self'"
    assert_includes policy, "frame-ancestors 'none'"
    assert_includes policy, "frame-src 'self' https://www.youtube.com https://www.youtube-nocookie.com"
    assert_includes policy, "https://challenges.cloudflare.com"
    assert_includes policy, "img-src 'self' https: data:"
    assert_includes policy, "object-src 'none'"
    assert_includes policy, "report-uri /csp-violation-reports"
    assert_match(/script-src 'self' https:\/\/challenges\.cloudflare\.com blob: 'nonce-[^']+'/i, policy)
    assert_match(/style-src 'self' 'nonce-[^']+'/i, policy)
    refute_includes policy, "nonce-''"
    refute_includes policy, "'unsafe-inline'"
    refute_includes policy, "'unsafe-eval'"
  end
end
