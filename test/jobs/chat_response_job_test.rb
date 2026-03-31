require "test_helper"

class ChatResponseJobTest < ActiveJob::TestCase
  test "delegates to the continuation runner" do
    chat = users(:one).chats.create!
    request_id = "req_1"
    calls = []
    fake_runner = Struct.new(:calls) do
      def run
        calls << :run
      end
    end.new(calls)

    with_overridden_singleton_method(ChatContinuationRunner, :new, ->(**kwargs) {
      calls << kwargs
      fake_runner
    }) do
      ChatResponseJob.perform_now(chat.id, request_id)
    end

    assert_equal 2, calls.length
    assert_equal({ chat: chat, request_id: request_id }, calls.first)
    assert_equal :run, calls.last
  end

  private

  def with_overridden_singleton_method(object, method_name, replacement)
    singleton_class = object.singleton_class
    original = object.method(method_name)
    singleton_class.define_method(method_name, replacement)
    yield
  ensure
    singleton_class.define_method(method_name, original)
  end
end
