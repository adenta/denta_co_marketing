module ChatContinuation
  class Persistence
    def initialize(chat:)
      @chat = chat
    end

    def persist_tool_result_payloads(tool_result_outputs:)
      return if tool_result_outputs.blank?

      ToolCall
        .joins(:message)
        .where(messages: { chat_id: chat.id }, tool_call_id: tool_result_outputs.keys)
        .includes(:result)
        .find_each do |tool_call|
          next unless tool_result_outputs.key?(tool_call.tool_call_id)

          result_message = tool_call.result
          next unless result_message

          output = tool_result_outputs[tool_call.tool_call_id]
          result_message.update!(
            content_raw: output,
            content: UiMessagePartsBuilder.human_readable_tool_output(output),
          )
        end
    rescue StandardError => error
      Rails.logger.warn("Failed to persist tool output payloads: #{error.class}: #{error.message}")
    end

    def persist_current_pass_state(state:)
      return unless state

      persist_tool_result_payloads(tool_result_outputs: state.tool_result_outputs)
      persist_partial_assistant_message(
        assistant_message_id: state.assistant_message_id,
        partial_content: state.partial_content,
      )
    end

    private

    attr_reader :chat

    def persist_partial_assistant_message(assistant_message_id:, partial_content:)
      return if partial_content.blank?

      assistant_message = find_assistant_message(assistant_message_id)
      return unless assistant_message

      assistant_message.update!(content: partial_content)
    rescue StandardError => error
      Rails.logger.warn("Failed to persist partial assistant message: #{error.class}: #{error.message}")
    end

    def find_assistant_message(assistant_message_id)
      if assistant_message_id.present?
        message = chat.messages.find_by(id: assistant_message_id)
        return message if message&.role.to_s == "assistant"
      end

      chat.messages.where(role: "assistant").order(:created_at, :id).last
    end
  end
end
