require "test_helper"

class Api::V1::PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "create returns not implemented" do
    post api_v1_passwords_path, params: { email_address: users(:one).email_address }, as: :json

    assert_response :not_implemented
    assert_equal(
      "Password reset is not available for this application.",
      response.parsed_body["message"],
    )
  end

  test "update returns not implemented" do
    patch api_v1_password_path("unused-token"), params: {
      password: "new",
      password_confirmation: "new"
    }, as: :json

    assert_response :not_implemented
    assert_equal(
      "Password reset is not available for this application.",
      response.parsed_body["message"],
    )
  end
end
