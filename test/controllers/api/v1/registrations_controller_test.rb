require "test_helper"

class Api::V1::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "create rejects authenticated users" do
    sign_in_as(users(:one))

    post api_v1_registration_path, params: {
      email_address: "new-user@example.com",
      password: "password",
      password_confirmation: "password"
    }, as: :json

    assert_response :conflict
    assert_equal root_url, response.parsed_body["redirect_to"]
  end

  test "create with valid attributes" do
    assert_difference("User.count", 1) do
      post api_v1_registration_path, params: {
        email_address: "new-user@example.com",
        password: "password",
        password_confirmation: "password"
      }, as: :json
    end

    assert_response :success
    assert cookies[:session_id]
    assert_equal root_url, response.parsed_body["redirect_to"]
  end

  test "create with duplicate email returns validation errors" do
    assert_no_difference("User.count") do
      post api_v1_registration_path, params: {
        email_address: users(:one).email_address,
        password: "password",
        password_confirmation: "password"
      }, as: :json
    end

    assert_response :unprocessable_entity
    assert_equal [ "Email address has already been taken" ], response.parsed_body.dig("errors", "email_address")
  end

  test "create with non matching passwords returns validation errors" do
    assert_no_difference("User.count") do
      post api_v1_registration_path, params: {
        email_address: "mismatch@example.com",
        password: "password",
        password_confirmation: "different"
      }, as: :json
    end

    assert_response :unprocessable_entity
    assert_equal [ "Password confirmation doesn't match Password" ], response.parsed_body.dig("errors", "password_confirmation")
  end
end
