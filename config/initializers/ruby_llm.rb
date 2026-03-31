RubyLLM.configure do |config|
  config.openrouter_api_key = ENV["OPENROUTER_API_KEY"]
  # OpenRouter uses the format: provider/model-name
  # For OpenRouter, you need to specify the full model path as it appears on openrouter.ai
  config.default_model = "openai/gpt-5.2-chat"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end
