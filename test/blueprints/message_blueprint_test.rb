require "test_helper"

class MessageBlueprintTest < ActiveSupport::TestCase
  test "serializes persisted tool calls into dynamic tool parts" do
    chat = users(:one).chats.create!
    assistant = chat.messages.create!(role: "assistant", content: "Checking SF weather...")
    tool_call = assistant.tool_calls.create!(
      tool_call_id: "call_123",
      name: "get_sf_weather",
      arguments: {}
    )
    chat.messages.create!(
      role: "tool",
      parent_tool_call: tool_call,
      content_raw: { location: "San Francisco, CA", temperature_f: 64, conditions: "Foggy", source: "mock" }
    )

    messages = chat.messages
      .where.not(role: "tool")
      .includes(tool_calls: :result)
      .order(:created_at)

    serialized = MessageBlueprint.render_as_hash(messages)
    assistant_payload = serialized.find { |message| message[:id] == assistant.id }
    tool_part = assistant_payload[:parts].find { |part| part[:type] == "dynamic-tool" }

    assert_equal "assistant", assistant_payload[:role]
    assert_equal "get_sf_weather", tool_part[:toolName]
    assert_equal "call_123", tool_part[:toolCallId]
    assert_equal "output-available", tool_part[:state]
    assert_equal 64, tool_part[:output]["temperature_f"] || tool_part[:output][:temperature_f]
  end
end
