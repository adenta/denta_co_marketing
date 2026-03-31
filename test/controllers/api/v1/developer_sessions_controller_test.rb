require "test_helper"

class Api::V1::DeveloperSessionsControllerTest < ActionDispatch::IntegrationTest
  test "create signs in an existing user in test" do
    user = User.order(:id).first

    post api_v1_developer_session_path, as: :json

    assert_response :success
    assert cookies[:session_id]
    assert_equal root_url, response.parsed_body["redirect_to"]
    assert_equal "Signed in as #{user.email_address}", response.parsed_body["message"]
  end

  test "create creates a dev user when no users exist" do
    User.delete_all

    assert_difference("User.count", 1) do
      post api_v1_developer_session_path, as: :json
    end

    assert_response :success
    assert_equal "dev@example.com", User.last.email_address
    assert_equal root_url, response.parsed_body["redirect_to"]
  end

  test "create rejects authenticated users" do
    sign_in_as(users(:one))

    post api_v1_developer_session_path, as: :json

    assert_response :conflict
    assert_equal root_url, response.parsed_body["redirect_to"]
  end

  test "create is unavailable outside development and test" do
    original_env = Rails.method(:env)

    Rails.singleton_class.send(:define_method, :env) do
      ActiveSupport::StringInquirer.new("production")
    end

    post api_v1_developer_session_path, as: :json

    assert_response :forbidden
    assert_equal new_session_path, response.parsed_body["redirect_to"]
  ensure
    Rails.singleton_class.send(:define_method, :env) do
      original_env.call
    end
  end
end
