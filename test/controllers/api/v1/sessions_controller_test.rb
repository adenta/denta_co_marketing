require "test_helper"

class Api::V1::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:one) }

  test "create rejects authenticated users" do
    sign_in_as(@user)

    post api_v1_session_path, params: {
      email_address: @user.email_address,
      password: "password"
    }, as: :json

    assert_response :conflict
    assert_equal root_url, response.parsed_body["redirect_to"]
  end

  test "create with valid credentials" do
    post api_v1_session_path, params: {
      email_address: @user.email_address,
      password: "password"
    }, as: :json

    assert_response :success
    assert cookies[:session_id]
    assert_equal root_url, response.parsed_body["redirect_to"]
  end

  test "create with invalid credentials returns validation errors" do
    post api_v1_session_path, params: {
      email_address: @user.email_address,
      password: "wrong"
    }, as: :json

    assert_response :unprocessable_entity
    assert_nil cookies[:session_id]
    assert_equal [ "Try another email address or password." ], response.parsed_body.dig("errors", "base")
  end

  test "destroy clears the session and returns sign in redirect" do
    sign_in_as(@user)

    delete api_v1_session_path, as: :json

    assert_response :success
    assert_equal new_session_path, response.parsed_body["redirect_to"]
    assert_empty cookies[:session_id]
  end

  test "destroy requires authentication" do
    delete api_v1_session_path, as: :json

    assert_response :unauthorized
    assert_equal new_session_path, response.parsed_body["redirect_to"]
  end
end
