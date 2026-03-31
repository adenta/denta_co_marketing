require "test_helper"

class ChatContinuation::JudgeChatBuilderTest < ActiveSupport::TestCase
  test "builds an ephemeral judge chat from the persisted transcript in order" do
    chat = users(:one).chats.create!
    chat.create_user_message("Do the weather task")

    assistant = chat.messages.create!(role: "assistant", content: "Checking the weather.")
    tool_call = assistant.tool_calls.create!(
      tool_call_id: "call_weather",
      name: "get_sf_weather",
      arguments: {},
    )
    chat.messages.create!(
      role: "tool",
      parent_tool_call: tool_call,
      content_raw: {
        location: "San Francisco, CA",
        temperature_f: 61,
        conditions: "Partly cloudy",
        source: "mock"
      },
      content: "{\"location\":\"San Francisco, CA\"}",
    )
    chat.messages.create!(role: "assistant", content: "Finished the weather task.")

    judge_chat = ChatContinuation::JudgeChatBuilder.new(chat: chat).call

    assert_equal(
      %w[system user assistant tool assistant],
      judge_chat.messages.map { |message| message.role.to_s },
    )
    assert_equal ChatContinuation::Judge::INSTRUCTIONS, judge_chat.messages.first.content
    assert_equal "Do the weather task", judge_chat.messages[1].content
    assert_includes judge_chat.messages[2].tool_calls.keys, "call_weather"
    assert_equal "get_sf_weather", judge_chat.messages[2].tool_calls.fetch("call_weather").name
    assert_equal(
      {
        "location" => "San Francisco, CA",
        "temperature_f" => 61,
        "conditions" => "Partly cloudy",
        "source" => "mock"
      },
      judge_chat.messages[3].content.value,
    )
    assert_equal "Finished the weather task.", judge_chat.messages[4].content
  end
end
