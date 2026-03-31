class ChatResponseJob < ApplicationJob
  queue_as :default

  def perform(chat_id, request_id)
    chat = Chat.find(chat_id)
    ChatContinuationRunner.new(chat: chat, request_id: request_id).run
  end
end
