require "test_helper"

class ChatTest < ActiveSupport::TestCase
  test "defaults agent_type to AssistantAgent" do
    chat = users(:one).chats.create!

    assert_equal "AssistantAgent", chat.agent_type
  end

  test "rejects an invalid agent_type" do
    chat = users(:one).chats.build(agent_type: "NotARealAgent")

    refute chat.valid?
    assert_includes chat.errors[:agent_type], "is not a valid RubyLLM agent"
  end

  test "builds a configured agent instance" do
    chat = users(:one).chats.create!

    assert_instance_of AssistantAgent, chat.agent
    assert_equal chat, chat.agent.chat
  end

  test "delegates metadata to AssistantAgent" do
    chat = users(:one).chats.create!

    assert_equal "Chat #{chat.id}", chat.display_name
    assert_nil chat.linked_resource
  end

  test "builds a slot machine agent instance" do
    chat = users(:one).chats.create!(agent_type: "SlotMachineAgent")

    assert_instance_of SlotMachineAgent, chat.agent
    assert_equal "Slot machine", chat.display_name
    assert_nil chat.linked_resource
  end

  test "discovers available chat agent types from agent files" do
    assert_equal [ "AssistantAgent", "SlotMachineAgent" ], Chat.available_agent_types
  end
end
