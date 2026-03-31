require "test_helper"

class ChatPolicyTest < ActiveSupport::TestCase
  test "show allows the owner" do
    user = users(:one)
    chat = user.chats.create!

    assert ChatPolicy.new(user, chat).show?
  end

  test "show denies a different user" do
    chat = users(:one).chats.create!

    refute ChatPolicy.new(users(:two), chat).show?
  end

  test "create requires an authenticated user" do
    assert ChatPolicy.new(users(:one), Chat).create?
    refute ChatPolicy.new(nil, Chat).create?
  end
end
