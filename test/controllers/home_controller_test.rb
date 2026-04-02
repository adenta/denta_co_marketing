require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "index renders the splash page for signed out visitors" do
    get root_path

    assert_response :success
    assert_includes @response.body, "home/index"
    assert_includes @response.body, "A friendly place to think through useful AI and the software around it."
    assert_includes @response.body, "<title>Andrew Denta</title>"
    assert_includes @response.body, '<meta name="description" content="A personal site and blog about useful AI, software, systems, and the operational friction that shapes real work.">'
    assert_includes @response.body, "navigation/AuthControls"
    refute_includes @response.body, "navigation/Navbar"
    assert_includes @response.body, "&quot;developer_sign_in_enabled&quot;:true"
    refute_includes @response.body, "available_agents"
    refute_includes @response.body, "&quot;sign_in_path&quot;"
    refute_includes @response.body, "&quot;sign_up_path&quot;"
  end

  test "index renders the splash page for signed in users" do
    sign_in_as(users(:one))

    get root_path

    assert_response :success
    assert_includes @response.body, "home/index"
    assert_includes @response.body, "navigation/AuthControls"
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
    refute_includes @response.body, "navigation/AuthControls"
  ensure
    Rails.define_singleton_method(:env, original_env_method)
  end
end
