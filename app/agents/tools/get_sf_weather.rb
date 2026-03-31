module Tools
  class GetSfWeather < RubyLLM::Tool
    description "Return the current weather in San Francisco."

    params do
    end

    def execute
      {
        location: "San Francisco, CA",
        temperature_f: rand(52..72),
        conditions: [ "Sunny", "Foggy", "Partly cloudy", "Windy" ].sample,
        source: "mock"
      }
    end
  end
end
