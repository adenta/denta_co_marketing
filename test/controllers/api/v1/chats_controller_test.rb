require "test_helper"

class Api::V1::ChatsControllerTest < ActionDispatch::IntegrationTest
  test "create returns unauthorized JSON when signed out" do
    post api_v1_chats_path, as: :json

    assert_response :unauthorized
    assert_equal new_session_path, response.parsed_body["redirect_to"]
  end

  test "create makes an owned chat and returns its redirect target" do
    user = users(:one)
    sign_in_as(user)

    assert_difference("Chat.count", 1) do
      post api_v1_chats_path, as: :json
    end

    assert_response :success

    chat = Chat.order(:created_at).last
    assert_equal user.id, chat.user_id
    assert_equal "AssistantAgent", chat.agent_type
    assert_equal chat.id, response.parsed_body["id"]
    assert_equal chat_path(chat), response.parsed_body["redirect_to"]
  end

  test "create rejects an invalid agent type" do
    sign_in_as(users(:one))

    assert_no_difference("Chat.count") do
      post api_v1_chats_path, params: { agent_type: "NotARealAgent" }, as: :json
    end

    assert_response :unprocessable_entity
    assert_equal "Invalid agent type.", response.parsed_body["message"]
  end

  test "create accepts SlotMachineAgent as an explicit agent type" do
    sign_in_as(users(:one))

    post api_v1_chats_path, params: { agent_type: "SlotMachineAgent" }, as: :json

    assert_response :success
    assert_equal "SlotMachineAgent", Chat.order(:created_at).last.agent_type
  end
end
