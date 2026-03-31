module ChatContinuation
  class PassState
    attr_accessor :assistant_message_id, :partial_content
    attr_reader :text_part_id, :tool_call_queue, :tool_result_outputs

    def initialize
      @assistant_message_id = nil
      @partial_content = +""
      @text_part_id = SecureRandom.uuid
      @tool_call_queue = []
      @tool_result_outputs = {}
    end

    def record_tool_call(tool_call)
      @tool_call_queue << tool_call
    end

    def next_tool_call
      @tool_call_queue.shift
    end

    def record_tool_result(tool_call:, output:, error_text:)
      @tool_result_outputs[tool_call.id] = output
    end
  end
end
