module ChatContinuation
  class JudgeChatBuilder
    def initialize(chat:, judge_model: nil)
      @chat = chat
      @judge_model = judge_model.presence
    end

    def call
      RubyLLM.chat(**resolved_chat_options).tap do |judge_chat|
        chat.messages
          .includes(:parent_tool_call, tool_calls: :result)
          .order(:created_at, :id)
          .each do |message|
            judge_chat.add_message(message.to_llm)
          end

        judge_chat.with_instructions(ChatContinuation::Judge::INSTRUCTIONS)
      end
    end

    private

    attr_reader :chat, :judge_model

    def resolved_chat_options
      return { model: judge_model } if judge_model.present?

      provider = chat.provider
      model_id = chat.model_id

      if provider.present? && model_id.present?
        {
          model: model_id,
          provider: provider.to_sym,
          assume_model_exists: true
        }
      else
        { model: RubyLLM.config.default_model }
      end
    end
  end
end
