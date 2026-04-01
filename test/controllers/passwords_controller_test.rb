require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "new returns not implemented" do
    get new_password_path
    assert_response :not_implemented
    assert_equal "Password reset is not available for this application.", @response.body
  end

  test "new returns not implemented for authenticated users" do
    sign_in_as(users(:one))

    get new_password_path

    assert_response :not_implemented
    assert_equal "Password reset is not available for this application.", @response.body
  end

  test "edit returns not implemented" do
    get edit_password_path("unused-token")
    assert_response :not_implemented
    assert_equal "Password reset is not available for this application.", @response.body
  end

  test "edit returns not implemented for authenticated users" do
    sign_in_as(users(:one))

    get edit_password_path("unused-token")

    assert_response :not_implemented
    assert_equal "Password reset is not available for this application.", @response.body
  end
end
