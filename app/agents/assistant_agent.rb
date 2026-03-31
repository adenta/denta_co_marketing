class AssistantAgent < RubyLLM::Agent
  chat_model Chat
  model RubyLLM.config.default_model

  instructions <<~INSTRUCTIONS
    You are a helpful assistant for this Rails app.
    If the user asks about San Francisco weather, call the get_sf_weather tool.
    Keep answers concise and accurate.
  INSTRUCTIONS

  tools Tools::GetSfWeather

  def self.allowed_chatable_types
    []
  end

  def self.allows_nil_chatable?
    true
  end

  def self.validate_chatable!(_chat)
    true
  end

  def self.display_name(chat)
    "Chat #{chat.id}"
  end

  def self.list_name
    "Assistant"
  end

  def self.linked_resource(_chat)
    nil
  end
end
