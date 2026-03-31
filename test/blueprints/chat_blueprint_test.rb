require "test_helper"

class ChatBlueprintTest < ActiveSupport::TestCase
  test "serializes chat list attributes" do
    chat = users(:one).chats.create!

    serialized = ChatBlueprint.render_as_hash(chat)

    assert_equal chat.id, serialized[:id]
    assert_equal "AssistantAgent", serialized[:agent_type]
    assert_equal "Chat #{chat.id}", serialized[:display_name]
    assert_equal Rails.application.routes.url_helpers.chat_path(chat), serialized[:path]
    assert_equal chat.updated_at.iso8601, serialized[:updated_at]
    assert_nil serialized[:chatable_type]
    assert_nil serialized[:chatable_id]
    assert_nil serialized[:linked_resource]
  end
end
