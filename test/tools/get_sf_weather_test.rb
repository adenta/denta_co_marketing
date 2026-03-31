require "test_helper"

module Tools
  class GetSfWeatherTest < ActiveSupport::TestCase
    test "returns a json-safe sf weather payload" do
      result = Tools::GetSfWeather.new.execute

      assert_equal "San Francisco, CA", result[:location]
      assert_includes 52..72, result[:temperature_f]
      assert_includes [ "Sunny", "Foggy", "Partly cloudy", "Windy" ], result[:conditions]
      assert_equal "mock", result[:source]
    end
  end
end
