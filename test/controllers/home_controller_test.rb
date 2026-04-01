require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "index renders the splash page for signed out visitors" do
    get root_path

    assert_response :success
    assert_includes @response.body, "home/index"
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
    assert_includes @response.body, users(:one).email_address
    refute_includes @response.body, "available_agents"
  end
end
