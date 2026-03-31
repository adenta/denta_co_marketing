require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_registration_path

    assert_response :success
    assert_includes @response.body, "registrations/new"
  end

  test "new redirects authenticated users to the root path" do
    sign_in_as(users(:one))

    get new_registration_path

    assert_redirected_to root_path
  end
end
