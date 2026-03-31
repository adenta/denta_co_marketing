class ChatChannel < ApplicationCable::Channel
  def subscribed
    @chat = verified_chat
    reject unless @chat

    stream_for @chat
  end

  def start(data)
    request_id = data.fetch("request_id", "").to_s
    trigger = data.fetch("trigger", "").to_s

    unless trigger == "submit-message"
      return broadcast_error(request_id, "Only submit-message is supported.")
    end

    content = extract_last_user_text(data["messages"])
    if content.blank?
      return broadcast_error(request_id, "No user message content provided.")
    end

    @chat.create_user_message(content)
    ChatResponseJob.perform_later(@chat.id, request_id)
  end

  def cancel(data)
    request_id = data["request_id"].to_s
    return if request_id.blank?

    Rails.cache.write(cancel_key(request_id), true, expires_in: 30.minutes)
  end

  private

  def verified_chat
    chat_id = params["chat_id"].to_s
    return nil if chat_id.blank? || current_user.blank?

    current_user.chats.find_by(id: chat_id)
  end

  def extract_last_user_text(messages)
    user_message = Array(messages).last
    return "" unless user_message.is_a?(Hash) && user_message["role"] == "user"

    parts = Array(user_message["parts"])
    text = parts
      .select { |part| part.is_a?(Hash) && part["type"] == "text" }
      .map { |part| part["text"].to_s }
      .join

    return text if text.present?

    user_message["content"].to_s
  end

  def broadcast_error(request_id, error)
    self.class.broadcast_to(
      @chat,
      {
        event: "error",
        request_id: request_id,
        seq: 1,
        error: error
      },
    )
  end

  def cancel_key(request_id)
    "chat-request-cancelled:#{request_id}"
  end
end
