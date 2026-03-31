class ChatContinuationRunner
  class CancelledRequest < StandardError; end

  DEFAULT_MAX_MESSAGES = 10
  CONTINUE_VERDICT = "continue"
  DONE_VERDICT = "done"
  BLOCKED_VERDICT = "blocked"
  VERDICTS = [
    CONTINUE_VERDICT,
    DONE_VERDICT,
    BLOCKED_VERDICT
  ].freeze

  CONTINUATION_INSTRUCTIONS = <<~INSTRUCTIONS.freeze
    Continue working on the user's current request.
    Do not ask for confirmation or permission to keep going unless you are blocked by
    missing requirements, ambiguous instructions, contradictory constraints, or a risky
    or destructive action.
    If straightforward work remains, keep going and do it.
  INSTRUCTIONS

  SUMMARY_ONLY_INSTRUCTIONS = <<~INSTRUCTIONS.freeze
    You have reached the autonomous continuation limit for this run.
    Do not call tools.
    Briefly summarize what you completed, what still remains, and the next concrete step.
  INSTRUCTIONS

  attr_reader :chat, :request_id

  def initialize(
    chat:,
    request_id:,
    broadcaster: ChatChannel,
    cache: Rails.cache,
    agent_factory: nil,
    judge_resolver: nil,
    max_messages: nil,
    judge_model: nil
  )
    @chat = chat
    @request_id = request_id
    @broadcaster = broadcaster
    @cache = cache
    @agent_factory = agent_factory
    @judge_resolver = judge_resolver
    @judge_model = judge_model
    @max_messages = normalize_max_messages(max_messages)
    @event_broadcaster = ChatContinuation::Broadcaster.new(
      chat: chat,
      request_id: request_id,
      broadcaster: broadcaster,
    )
    @persistence = ChatContinuation::Persistence.new(chat: chat)
    @pass_executor = ChatContinuation::PassExecutor.new(
      chat: chat,
      agent_factory: agent_factory,
      broadcaster: event_broadcaster,
      persistence: persistence,
      cancellation_guard: method(:ensure_not_cancelled!),
    )
  end

  def run
    next_pass_instructions = nil

    max_messages.times do
      ensure_not_cancelled!

      pass_executor.call(
        runtime_instructions: next_pass_instructions,
        summary_only: false,
      )

      ensure_not_cancelled!

      verdict = judge.call

      case verdict.fetch(:verdict)
      when CONTINUE_VERDICT
        next_pass_instructions = CONTINUATION_INSTRUCTIONS
      when DONE_VERDICT, BLOCKED_VERDICT
        event_broadcaster.done
        return
      end
    end

    ensure_not_cancelled!

    pass_executor.call(
      runtime_instructions: SUMMARY_ONLY_INSTRUCTIONS,
      summary_only: true,
    )

    event_broadcaster.done
  rescue CancelledRequest
    persistence.persist_current_pass_state(state: pass_executor.current_state)
    event_broadcaster.chunk(type: "abort", reason: "user-cancelled")
    event_broadcaster.done
  rescue StandardError => error
    persistence.persist_current_pass_state(state: pass_executor.current_state)
    event_broadcaster.error(error.message)
  ensure
    cache.delete(cancel_key(request_id))
  end

  private

  attr_reader :agent_factory, :broadcaster, :cache, :event_broadcaster, :judge_model, :judge_resolver,
    :max_messages, :pass_executor, :persistence

  def judge
    ChatContinuation::Judge.new(
      chat: chat,
      judge_resolver: judge_resolver,
      judge_model: judge_model,
    )
  end

  def ensure_not_cancelled!
    raise CancelledRequest if cancelled?(request_id)
  end

  def cancelled?(request_id)
    cache.read(cancel_key(request_id)) == true
  end

  def cancel_key(request_id)
    "chat-request-cancelled:#{request_id}"
  end

  def normalize_max_messages(value)
    parsed = value.to_i if value.present?
    parsed = ENV.fetch("CHAT_CONTINUATION_MAX_MESSAGES", DEFAULT_MAX_MESSAGES.to_s).to_i if parsed.blank? || parsed <= 0
    parsed.positive? ? parsed : DEFAULT_MAX_MESSAGES
  end
end
