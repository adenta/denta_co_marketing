require "test_helper"

class AhoyTrackingTest < ActionDispatch::IntegrationTest
  test "html page requests create ahoy visits" do
    assert_difference("Ahoy::Visit.count", 1) do
      get root_path
    end

    assert_response :success

    visit = Ahoy::Visit.order(:started_at).last
    assert_equal root_url, visit.landing_page
  end

  test "ahoy events endpoint records js page views for the current visit" do
    get root_path
    visit = Ahoy::Visit.order(:started_at).last
    event_id = SecureRandom.uuid

    assert_difference("Ahoy::Event.count", 1) do
      post "/ahoy/events",
        params: [
          {
            id: event_id,
            name: "$view",
            properties: {
              page: "/",
              title: "Home",
              url: root_url,
            },
            time: Time.current.iso8601,
          },
        ].to_json,
        headers: {
          "CONTENT_TYPE" => "application/json",
          "Ahoy-Visit" => cookies["ahoy_visit"],
          "Ahoy-Visitor" => cookies["ahoy_visitor"],
        }
    end

    assert_response :success

    event = Ahoy::Event.order(:time).last
    assert_equal visit.id, event.visit_id
    assert_equal "$view", event.name
    assert_equal "/", event.properties["page"]
  end
end
