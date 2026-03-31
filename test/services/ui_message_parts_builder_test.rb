require "test_helper"
require "json"

class UiMessagePartsBuilderTest < ActiveSupport::TestCase
  test "builds assistant parts and prefers structured content_raw for tool output" do
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
      content: "{:location=>\"San Francisco, CA\"}",
      content_raw: { "location" => "San Francisco, CA", "temperature_f" => 61, "conditions" => "Partly cloudy", "source" => "mock" }
    )

    parts = UiMessagePartsBuilder.build(assistant)
    tool_part = parts.find { |part| part[:type] == "dynamic-tool" }

    assert_equal "text", parts.first[:type]
    assert_equal "output-available", tool_part[:state]
    assert_equal "San Francisco, CA", tool_part[:output]["location"]
    refute_match(/=>/, JSON.generate(tool_part[:output]))
  end
end
