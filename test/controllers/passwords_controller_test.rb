require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = User.take }

  test "new" do
    get new_password_path
    assert_response :success
    assert_page_mount "passwords/new"
  end

  test "new redirects authenticated users to the root path" do
    sign_in_as(users(:one))

    get new_password_path

    assert_redirected_to root_path
  end

  test "edit" do
    get edit_password_path(@user.password_reset_token)
    assert_response :success
    assert_page_mount "passwords/edit"
  end

  test "edit redirects authenticated users to the root path" do
    sign_in_as(users(:one))

    get edit_password_path(@user.password_reset_token)

    assert_redirected_to root_path
  end

  test "edit with invalid password reset token" do
    get edit_password_path("invalid token")
    assert_redirected_to new_password_path

    follow_redirect!
    assert_flash_toast "Password reset link is invalid"
  end

  private
    def assert_page_mount(component_name)
      assert_includes @response.body, component_name
    end

    def assert_flash_toast(text)
      assert_includes @response.body, "utils/ToastContainer"
      assert_includes @response.body, text
    end
end
