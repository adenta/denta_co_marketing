require "test_helper"

class Api::V1::PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "create rejects authenticated users" do
    sign_in_as(@user)

    post api_v1_passwords_path, params: { email_address: @user.email_address }, as: :json

    assert_response :conflict
    assert_equal root_url, response.parsed_body["redirect_to"]
  end

  test "create queues reset email and returns redirect target" do
    post api_v1_passwords_path, params: { email_address: @user.email_address }, as: :json

    assert_response :success
    assert_enqueued_email_with PasswordsMailer, :reset, args: [ @user ]
    assert_equal new_session_path, response.parsed_body["redirect_to"]
  end

  test "update resets the password and returns redirect target" do
    patch api_v1_password_path(@user.password_reset_token), params: {
      password: "new",
      password_confirmation: "new"
    }, as: :json

    assert_response :success
    assert_equal new_session_path, response.parsed_body["redirect_to"]
    assert_equal true, @user.reload.authenticate("new").present?
  end

  test "update with non matching passwords returns validation errors" do
    patch api_v1_password_path(@user.password_reset_token), params: {
      password: "new",
      password_confirmation: "different"
    }, as: :json

    assert_response :unprocessable_entity
    assert_equal [ "Password confirmation doesn't match Password" ], response.parsed_body.dig("errors", "password_confirmation")
  end

  test "update with invalid token returns redirect target" do
    patch api_v1_password_path("invalid-token"), params: {
      password: "new",
      password_confirmation: "new"
    }, as: :json

    assert_response :not_found
    assert_equal new_password_path, response.parsed_body["redirect_to"]
  end

  test "update rejects authenticated users" do
    sign_in_as(@user)

    patch api_v1_password_path(@user.password_reset_token), params: {
      password: "new",
      password_confirmation: "new"
    }, as: :json

    assert_response :conflict
    assert_equal root_url, response.parsed_body["redirect_to"]
  end
end
