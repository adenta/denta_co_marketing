require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_session_path
    assert_response :success
    assert_page_mount "sessions/new"
  end

  test "new redirects authenticated users to the root path" do
    sign_in_as(users(:one))

    get new_session_path

    assert_redirected_to root_path
  end

  private
    def assert_page_mount(component_name)
      assert_includes @response.body, component_name
    end
end
