require "test_helper"

class ChatsControllerTest < ActionDispatch::IntegrationTest
  test "index redirects unauthenticated users to sign in" do
    get chats_path

    assert_redirected_to new_session_path
  end

  test "index renders only the signed in users chats" do
    user = users(:one)
    newest_chat = user.chats.create!
    older_chat = user.chats.create!
    other_chat = users(:two).chats.create!
    older_chat.update_column(:updated_at, 1.day.ago)
    newest_chat.update_column(:updated_at, Time.current)
    sign_in_as(user)

    get chats_path

    assert_response :success
    assert_includes @response.body, "chats/index"
    assert_includes @response.body, "navigation/SiteNav"
    assert_includes @response.body, newest_chat.id
    assert_includes @response.body, older_chat.id
    assert_includes @response.body, "available_agents"
    assert_includes @response.body, "Assistant"
    assert_includes @response.body, "Slot machine"
    refute_includes @response.body, other_chat.id
  end

  test "show redirects unauthenticated users to sign in" do
    chat = users(:one).chats.create!

    get chat_path(chat)

    assert_redirected_to new_session_path
  end

  test "show renders the chat page for the owner" do
    user = users(:one)
    chat = user.chats.create!
    sign_in_as(user)

    get chat_path(chat)

    assert_response :success
    assert_includes @response.body, "chats/show"
    assert_includes @response.body, "navigation/SiteNav"
  end

  test "show mounts serialized chat props" do
    user = users(:one)
    chat = user.chats.create!
    chat.messages.create!(role: "user", content: "What is the weather in SF?")
    assistant = chat.messages.create!(role: "assistant", content: "Checking SF weather...")
    tool_call = assistant.tool_calls.create!(
      tool_call_id: "call_123",
      name: "get_sf_weather",
      arguments: {}
    )
    chat.messages.create!(
      role: "tool",
      parent_tool_call: tool_call,
      content_raw: {
        "location" => "San Francisco, CA",
        "temperature_f" => 61,
        "conditions" => "Partly cloudy",
        "source" => "mock"
      }
    )
    sign_in_as(user)

    get chat_path(chat)

    assert_response :success
    assert_includes @response.body, chat.id
    assert_includes @response.body, "AssistantAgent"
    assert_includes @response.body, "Chat #{chat.id}"
    assert_includes @response.body, "Checking SF weather..."
    assert_includes @response.body, "get_sf_weather"
    assert_includes @response.body, "San Francisco, CA"
  end

  test "show returns not found for a different user" do
    sign_in_as(users(:two))
    chat = users(:one).chats.create!

    get chat_path(chat)

    assert_response :not_found
  end
end
