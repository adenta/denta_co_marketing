class ChatContinuationJudgeSchema < RubyLLM::Schema
  string :verdict, enum: ChatContinuationRunner::VERDICTS
  string :reason
end
