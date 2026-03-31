module ChatContinuation
  class Judge
    INSTRUCTIONS = <<~INSTRUCTIONS.freeze
      You are deciding whether the assistant should continue working on the user's latest
      request in the same autonomous run.

      Return:
      - continue: more straightforward work remains and the assistant can keep going without
        asking the user anything first
      - done: the user's request is satisfied for now
      - blocked: the assistant needs user clarification, missing requirements, or approval

      Favor done over continue when the remaining work is speculative or optional.
    INSTRUCTIONS

    def initialize(chat:, judge_resolver: nil, judge_model: nil)
      @chat = chat
      @judge_resolver = judge_resolver
      @judge_model = judge_model.presence
    end

    def call
      judge_chat = build_judge_chat

      verdict =
        if judge_resolver
          judge_resolver.call(judge_chat)
        else
          response = judge_chat.with_schema(ChatContinuationJudgeSchema).ask(judge_prompt)
          response.content
        end

      normalize_verdict_payload(verdict)
    end

    private

    attr_reader :chat, :judge_model, :judge_resolver

    def build_judge_chat
      JudgeChatBuilder.new(chat: chat, judge_model: judge_model).call
    end

    def judge_prompt
      "Based on the conversation so far, should the assistant continue working?"
    end

    def normalize_verdict_payload(payload)
      if payload.is_a?(Hash)
        verdict = payload[:verdict] || payload["verdict"]
        reason = payload[:reason] || payload["reason"]

        return {
          verdict: normalize_verdict(verdict),
          reason: reason.to_s
        }
      end

      {
        verdict: normalize_verdict(payload),
        reason: ""
      }
    end

    def normalize_verdict(value)
      normalized = value.to_s.downcase
      return normalized if valid_verdicts.include?(normalized)

      ChatContinuationRunner::DONE_VERDICT
    end

    def valid_verdicts
      ChatContinuationRunner::VERDICTS
    end
  end
end
