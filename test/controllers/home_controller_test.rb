require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "index mounts the shared chat props for the signed in user" do
    sign_in_as(users(:one))

    get root_path

    assert_response :success
    assert_includes @response.body, "home/index"
    assert_includes @response.body, "available_agents"
    assert_includes @response.body, "Assistant"
    assert_includes @response.body, "Slot machine"
  end
end
