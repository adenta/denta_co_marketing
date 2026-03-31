module ChatAgents
  class SfWeatherAgent < RubyLLM::Agent
    model RubyLLM.config.default_model

    instructions <<~INSTRUCTIONS
      You are a helpful assistant for this Rails app.
      If the user asks about San Francisco weather, call the get_sf_weather tool.
      Keep answers concise and accurate.
    INSTRUCTIONS

    tools Tools::GetSfWeather
  end
end
