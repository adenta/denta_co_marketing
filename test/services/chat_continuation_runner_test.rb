require "test_helper"
require "ostruct"

class ChatContinuationRunnerTest < ActiveSupport::TestCase
  class FakeJudgeChat
    attr_reader :instructions, :last_prompt, :messages

    def initialize(content:)
      @content = content
      @messages = []
    end

    def with_schema(_schema)
      self
    end

    def with_instructions(instructions)
      @instructions = instructions
      self
    end

    def add_message(message)
      @messages << message
      self
    end

    def ask(prompt)
      @last_prompt = prompt
      OpenStruct.new(content: @content)
    end
  end

  class FakeAgent
    attr_reader :chat, :observed_tool_choice

    def initialize(chat:, step:)
      @chat = chat
      @step = step
    end

    def on_new_message(&block)
      @on_new_message = block
      self
    end

    def on_tool_call(&block)
      @on_tool_call = block
      self
    end

    def on_tool_result(&block)
      @on_tool_result = block
      self
    end

    def complete
      @observed_tool_choice = chat.to_llm.tool_prefs[:choice]

      if (tool = @step[:tool])
        assistant = chat.messages.create!(role: "assistant", content: @step[:tool_preamble].to_s)
        tool_call = assistant.tool_calls.create!(
          tool_call_id: tool.fetch(:id, SecureRandom.uuid),
          name: tool.fetch(:name),
          arguments: tool.fetch(:input, {}),
        )
        @on_new_message&.call
        @on_tool_call&.call(
          OpenStruct.new(
            id: tool_call.tool_call_id,
            name: tool_call.name,
            arguments: tool_call.arguments,
          ),
        )
        chat.messages.create!(
          role: "tool",
          parent_tool_call: tool_call,
          content: tool.fetch(:output).to_json,
        )
        @on_tool_result&.call(tool.fetch(:output))
      end

      assistant = chat.messages.create!(role: "assistant", content: "")
      @on_new_message&.call

      text = @step[:text].to_s
      yield OpenStruct.new(content: text) if text.present?
      assistant.update!(content: text)
    end
  end

  test "streams tool call and tool result chunks in sequence" do
    chat = users(:one).chats.create!
    chat.create_user_message("Check the weather")

    broadcasts = []
    runner = build_runner(
      chat: chat,
      broadcasts: broadcasts,
      agent_steps: [
        {
          tool: {
            id: "call_123",
            name: "get_sf_weather",
            input: {},
            output: {
              location: "San Francisco, CA",
              temperature_f: 64,
              conditions: "Foggy",
              source: "mock"
            }
          },
          text: "It is 64F and foggy in San Francisco."
        }
      ],
      judge_verdicts: [ { verdict: "done", reason: "finished" } ],
    )

    runner.run

    assert broadcasts.any?, "expected broadcasts to be emitted"
    assert_equal broadcasts.size, broadcasts.map { |payload| payload[:seq] }.uniq.size
    assert_equal (1..broadcasts.size).to_a, broadcasts.map { |payload| payload[:seq] }

    chunk_types = broadcasts
      .select { |payload| payload[:event] == "chunk" }
      .map { |payload| payload.dig(:chunk, :type) }

    assert_includes chunk_types, "tool-input-available"
    assert_includes chunk_types, "tool-output-available"
    assert_includes chunk_types, "text-delta"
    assert_equal "done", broadcasts.last[:event]
  end

  test "continues across multiple assistant messages without a synthetic user message" do
    chat = users(:one).chats.create!
    chat.create_user_message("Build me a big storyboard")

    runner = build_runner(
      chat: chat,
      agent_steps: [
        { text: "I created scene one and scene two." },
        { text: "I added shots for the remaining scenes." }
      ],
      judge_verdicts: [
        { verdict: "continue", reason: "More straightforward work remains." },
        { verdict: "done", reason: "Task is complete." }
      ],
    )

    runner.run

    assistants = chat.messages.where(role: "assistant").order(:created_at, :id)

    assert_equal 2, assistants.count
    assert_equal(
      [
        "I created scene one and scene two.",
        "I added shots for the remaining scenes."
      ],
      assistants.pluck(:content),
    )
    assert_equal 1, chat.messages.where(role: "user").count
  end

  test "stops after a blocked verdict" do
    chat = users(:one).chats.create!
    chat.create_user_message("Do the thing")

    runner = build_runner(
      chat: chat,
      agent_steps: [ { text: "I need the output format before I continue." } ],
      judge_verdicts: [ { verdict: "blocked", reason: "Missing output format." } ],
    )

    runner.run

    assert_equal 1, chat.messages.where(role: "assistant").count
  end

  test "hits the cap and does one final summary-only generation" do
    chat = users(:one).chats.create!
    chat.create_user_message("Keep going until it is done")

    summary_agent = nil
    runner = build_runner(
      chat: chat,
      max_messages: 2,
      agent_steps: [
        { text: "Completed step one." },
        { text: "Completed step two." },
        { text: "I completed two steps. One step remains.", capture_agent: ->(agent) { summary_agent = agent } }
      ],
      judge_verdicts: [
        { verdict: "continue", reason: "Keep going." },
        { verdict: "continue", reason: "Still more work." }
      ],
    )

    runner.run

    assert_equal 3, chat.messages.where(role: "assistant").count
    assert_equal :none, summary_agent.observed_tool_choice
    assert_equal "I completed two steps. One step remains.", chat.messages.where(role: "assistant").order(:created_at, :id).last.content
  end

  test "cancel stops the whole run" do
    chat = users(:one).chats.create!
    chat.create_user_message("Keep working")

    cache = ActiveSupport::Cache::MemoryStore.new
    broadcasts = []

    runner = build_runner(
      chat: chat,
      broadcasts: broadcasts,
      cache: cache,
      agent_steps: [ { text: "Completed the first chunk." }, { text: "Should not run." } ],
      judge_verdicts: [
        lambda do |_payload|
          cache.write("chat-request-cancelled:req_cancel", true)
          { verdict: "continue", reason: "More work remains." }
        end
      ],
      request_id: "req_cancel",
    )

    runner.run

    assert_equal 1, chat.messages.where(role: "assistant").count
    assert_includes broadcasts.map { |payload| payload.dig(:chunk, :type) }, "abort"
    assert_equal "done", broadcasts.last[:event]
  end

  test "persists tool output across continued passes" do
    chat = users(:one).chats.create!
    chat.create_user_message("Do the weather task and continue")

    runner = build_runner(
      chat: chat,
      agent_steps: [
        {
          tool: {
            id: "call_abc",
            name: "get_sf_weather",
            input: {},
            output: {
              location: "San Francisco, CA",
              temperature_f: 61,
              conditions: "Partly cloudy",
              source: "mock"
            }
          },
          text: "Checked the weather."
        },
        { text: "Finished the remaining work." }
      ],
      judge_verdicts: [
        { verdict: "continue", reason: "Continue." },
        { verdict: "done", reason: "Finished." }
      ],
    )

    runner.run

    result_message = chat.messages.where(role: "tool").order(:created_at, :id).last

    assert_equal(
      {
        "location" => "San Francisco, CA",
        "temperature_f" => 61,
        "conditions" => "Partly cloudy",
        "source" => "mock"
      },
      result_message.content_raw,
    )
    assert_includes result_message.content, "\"location\""
  end

  test "uses the persisted chat model and provider for the judge by default" do
    chat = users(:one).chats.create!
    chat.with_model("openai/gpt-5.2-chat", provider: :openrouter, assume_exists: true)
    chat.create_user_message("Keep going")

    judge_chat = FakeJudgeChat.new(content: { verdict: "done", reason: "Finished." })
    chat_call = nil

    with_overridden_singleton_method(RubyLLM, :chat, ->(**kwargs) {
      chat_call = kwargs
      judge_chat
    }) do
      runner = build_runner(
        chat: chat,
        agent_steps: [ { text: "Completed the first chunk." } ],
        judge_verdicts: nil,
      )

      runner.run
    end

    assert_equal(
      {
        model: "openai/gpt-5.2-chat",
        provider: :openrouter,
        assume_model_exists: true
      },
      chat_call,
    )
  end

  test "uses a transcript-only judge prompt" do
    chat = users(:one).chats.create!
    chat.create_user_message("Keep going")

    judge_chat = FakeJudgeChat.new(content: { verdict: "done", reason: "Finished." })

    with_overridden_singleton_method(RubyLLM, :chat, ->(**_kwargs) { judge_chat }) do
      ChatContinuation::Judge.new(chat: chat).call
    end

    assert_equal "Based on the conversation so far, should the assistant continue working?", judge_chat.last_prompt
    refute_includes judge_chat.last_prompt, "Conversation context:"
  end

  test "clones the persisted transcript with inline tool results for the judge" do
    chat = users(:one).chats.create!
    chat.create_user_message("Do the weather task")

    observed_judge_chat = nil
    runner = build_runner(
      chat: chat,
      agent_steps: [
        {
          tool: {
            id: "call_weather",
            name: "get_sf_weather",
            input: {},
            output: {
              location: "San Francisco, CA",
              temperature_f: 61,
              conditions: "Partly cloudy",
              source: "mock"
            }
          },
          text: "Checked the weather."
        }
      ],
      judge_verdicts: [
        lambda do |judge_chat|
          observed_judge_chat = judge_chat
          { verdict: "done", reason: "Finished." }
        end
      ],
    )

    runner.run

    assert_equal(
      %w[system user assistant tool assistant],
      observed_judge_chat.messages.map { |message| message.role.to_s },
    )

    assert_equal ChatContinuation::Judge::INSTRUCTIONS, observed_judge_chat.messages.first.content

    assistant_with_tool_call = observed_judge_chat.messages[2]
    tool_message = observed_judge_chat.messages[3]

    assert_includes assistant_with_tool_call.tool_calls.keys, "call_weather"
    assert_equal "get_sf_weather", assistant_with_tool_call.tool_calls.fetch("call_weather").name
    assert_equal(
      {
        "location" => "San Francisco, CA",
        "temperature_f" => 61,
        "conditions" => "Partly cloudy",
        "source" => "mock"
      },
      tool_message.content.value,
    )
    assert_equal %w[user assistant tool assistant], chat.messages.order(:created_at, :id).pluck(:role)
  end

  test "broadcasts an error instead of silently finishing when the judge fails" do
    chat = users(:one).chats.create!
    chat.create_user_message("Keep working")

    broadcasts = []
    runner = build_runner(
      chat: chat,
      broadcasts: broadcasts,
      agent_steps: [ { text: "I completed the first chunk." } ],
      judge_verdicts: [
        lambda do |_judge_chat|
          raise RubyLLM::ModelNotFoundError, "Unknown model: openrouter/openai/gpt-5.2-chat"
        end
      ],
    )

    runner.run

    assert_equal 1, chat.messages.where(role: "assistant").count
    assert_equal "error", broadcasts.last[:event]
    assert_equal "Unknown model: openrouter/openai/gpt-5.2-chat", broadcasts.last[:error]
    refute_includes broadcasts.map { |payload| payload[:event] }, "done"
  end

  private

  def build_runner(chat:, agent_steps:, judge_verdicts: nil, broadcasts: nil, cache: Rails.cache, max_messages: nil, request_id: "req_1")
    steps = agent_steps.dup

    broadcaster = Module.new do
      define_singleton_method(:broadcast_to) do |_chat, payload|
        broadcasts << payload if broadcasts
      end
    end

    runner = ChatContinuationRunner.new(
      chat: chat,
      request_id: request_id,
      broadcaster: broadcaster,
      cache: cache,
      max_messages: max_messages,
      agent_factory: lambda do |chat_record|
        step = steps.shift or raise "No fake agent step available"
        agent = FakeAgent.new(chat: chat_record, step: step)
        step[:capture_agent]&.call(agent)
        agent
      end,
    )

    return runner if judge_verdicts.nil?

    verdicts = judge_verdicts.dup
    runner.instance_variable_set(
      :@judge_resolver,
      lambda do |judge_chat|
        verdict = verdicts.shift or raise "No fake judge verdict available"
        verdict.respond_to?(:call) ? verdict.call(judge_chat) : verdict
      end,
    )
    runner
  end

  def with_overridden_singleton_method(object, method_name, replacement)
    singleton_class = object.singleton_class
    original = object.method(method_name)
    singleton_class.define_method(method_name, replacement)
    yield
  ensure
    singleton_class.define_method(method_name, original)
  end
end
