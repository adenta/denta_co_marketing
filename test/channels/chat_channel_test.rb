require "test_helper"

class ChatChannelTest < ActionCable::Channel::TestCase
  tests ChatChannel

  test "subscribes to an owned chat" do
    user = users(:one)
    chat = user.chats.create!

    stub_connection current_user: user
    subscribe chat_id: chat.id

    assert subscription.confirmed?
    assert_has_stream_for chat
  end

  test "rejects subscriptions to another users chat" do
    chat = users(:one).chats.create!

    stub_connection current_user: users(:two)
    subscribe chat_id: chat.id

    assert subscription.rejected?
  end
end
