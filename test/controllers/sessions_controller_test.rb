require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_session_path
    assert_response :success
    assert_page_mount "sessions/new"
    assert_includes @response.body, "<title>Sign in | Andrew Denta</title>"
    assert_includes @response.body, '<meta name="description" content="Use your email address and password to continue.">'
    assert_includes @response.body, "&quot;create_path&quot;:&quot;/api/v1/session&quot;"
    refute_includes @response.body, "&quot;content&quot;:"
    refute_includes @response.body, "Reset it here"
    refute_includes @response.body, "Create one"
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
