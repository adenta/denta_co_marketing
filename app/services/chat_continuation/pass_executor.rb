module ChatContinuation
  class PassExecutor
    attr_reader :current_state

    def initialize(chat:, agent_factory:, broadcaster:, persistence:, cancellation_guard:)
      @chat = chat
      @agent_factory = agent_factory
      @broadcaster = broadcaster
      @persistence = persistence
      @cancellation_guard = cancellation_guard
      @current_state = nil
    end

    def call(runtime_instructions:, summary_only:)
      @current_state = PassState.new

      agent = build_agent(
        runtime_instructions: runtime_instructions,
        summary_only: summary_only,
      )

      register_callbacks(agent)

      broadcaster.chunk(type: "start")
      broadcaster.chunk(type: "text-start", id: current_state.text_part_id)

      begin
        agent.complete do |chunk|
          cancellation_guard.call
          next if chunk.content.blank?

          current_state.partial_content << chunk.content
          broadcaster.chunk(type: "text-delta", id: current_state.text_part_id, delta: chunk.content)
        end
      rescue StandardError => error
        Rails.logger.error(
          {
            event: "chat_continuation.pass_executor.complete_failed",
            chat_id: chat.id,
            assistant_message_id: current_state.assistant_message_id,
            text_part_id: current_state.text_part_id,
            partial_content_length: current_state.partial_content.length,
            runtime_instructions_present: runtime_instructions.present?,
            summary_only: summary_only,
            error_class: error.class.name,
            error_message: error.message
          }.to_json,
        )
        raise
      end

      persistence.persist_tool_result_payloads(tool_result_outputs: current_state.tool_result_outputs)

      broadcaster.chunk(type: "text-end", id: current_state.text_part_id)
      broadcaster.chunk(type: "finish")
    end

    private

    attr_reader :agent_factory, :broadcaster, :cancellation_guard, :chat, :persistence

    def build_agent(runtime_instructions:, summary_only:)
      reset_llm_chat!
      chat.with_runtime_instructions(runtime_instructions) if runtime_instructions.present?

      agent = agent_factory ? agent_factory.call(chat) : chat.agent
      chat.with_tools(replace: true, choice: :none) if summary_only
      agent
    end

    def register_callbacks(agent)
      agent.on_new_message do
        latest_message = chat.messages.order(:created_at, :id).last
        next unless latest_message&.role.to_s == "assistant"

        current_state.assistant_message_id = latest_message.id
      end

      agent.on_tool_call do |tool_call|
        current_state.record_tool_call(tool_call)
        broadcaster.chunk(
          type: "tool-input-available",
          dynamic: true,
          toolCallId: tool_call.id,
          toolName: tool_call.name,
          input: tool_call.arguments || {},
        )
      end

      agent.on_tool_result do |result|
        tool_call = current_state.next_tool_call
        next unless tool_call

        output = UiMessagePartsBuilder.normalize_tool_result(result)
        error_text = UiMessagePartsBuilder.tool_output_error_text(output)

        current_state.record_tool_result(
          tool_call: tool_call,
          output: output,
          error_text: error_text,
        )

        broadcaster.chunk(**tool_result_chunk(tool_call: tool_call, output: output, error_text: error_text))
      end
    end

    def tool_result_chunk(tool_call:, output:, error_text:)
      if error_text.present?
        {
          type: "tool-output-error",
          dynamic: true,
          toolCallId: tool_call.id,
          errorText: error_text
        }
      else
        {
          type: "tool-output-available",
          dynamic: true,
          toolCallId: tool_call.id,
          output: output
        }
      end
    end

    def reset_llm_chat!
      chat.instance_variable_set(:@chat, nil)
    end
  end
end
