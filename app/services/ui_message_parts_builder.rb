require "json"

class UiMessagePartsBuilder
  class << self
    def build(message)
      parts = []

      if message.content.present?
        parts << { type: "text", text: message.content }
      end

      return parts unless message.role.to_s == "assistant"

      message.tool_calls.each do |tool_call|
        parts << tool_part_for(tool_call)
      end

      parts
    end

    def tool_part_for(tool_call)
      input = normalize_json_value(tool_call.arguments)
      output_message = tool_call.result

      return {
        type: "dynamic-tool",
        toolName: tool_call.name,
        toolCallId: tool_call.tool_call_id,
        state: "input-available",
        input: input
      } unless output_message

      output = extract_output(output_message)
      error_text = tool_output_error_text(output)

      if error_text.present?
        {
          type: "dynamic-tool",
          toolName: tool_call.name,
          toolCallId: tool_call.tool_call_id,
          state: "output-error",
          input: input,
          errorText: error_text
        }
      else
        {
          type: "dynamic-tool",
          toolName: tool_call.name,
          toolCallId: tool_call.tool_call_id,
          state: "output-available",
          input: input,
          output: output
        }
      end
    end

    def normalize_tool_result(result)
      value = result.is_a?(RubyLLM::Tool::Halt) ? result.content : result

      normalized =
        case value
        when Hash, Array, Numeric, TrueClass, FalseClass, NilClass
          value
        when RubyLLM::Content::Raw
          value.value
        when RubyLLM::Content
          value.text
        else
          value.to_s
        end

      json_safe_value(normalized)
    end

    def tool_output_error_text(output)
      return output["error"].to_s if output.is_a?(Hash) && output["error"].present?
      return output[:error].to_s if output.is_a?(Hash) && output[:error].present?

      nil
    end

    def human_readable_tool_output(output)
      case output
      when Hash, Array
        JSON.pretty_generate(output)
      when NilClass
        ""
      else
        output.to_s
      end
    end

    private

    def extract_output(message)
      return normalize_json_value(message.content_raw) if message.respond_to?(:content_raw) && message.content_raw.present?

      normalize_json_value(message.content)
    end

    def normalize_json_value(value)
      return {} if value.nil?
      return value if value.is_a?(Hash) || value.is_a?(Array) || value.is_a?(Numeric) || value == true || value == false
      return value unless value.is_a?(String)

      string = value.strip
      return value if string.empty?
      return value unless string.start_with?("{", "[")

      JSON.parse(string)
    rescue JSON::ParserError
      value
    end

    def json_safe_value(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, nested_value), normalized|
          normalized[key.to_s] = json_safe_value(nested_value)
        end
      when Array
        value.map { |nested_value| json_safe_value(nested_value) }
      when Numeric, String, TrueClass, FalseClass, NilClass
        value
      else
        value.to_s
      end
    end
  end
end
