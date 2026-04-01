require "test_helper"

class RegistrationRoutesTest < ActionDispatch::IntegrationTest
  test "registration page route is missing" do
    get "/registration/new"

    assert_response :not_found
  end

  test "registration api route is missing" do
    post "/api/v1/registration", as: :json

    assert_response :not_found
  end
end
