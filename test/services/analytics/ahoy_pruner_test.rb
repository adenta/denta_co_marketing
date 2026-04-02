require "test_helper"

class Analytics::AhoyPrunerTest < ActiveSupport::TestCase
  test "prune removes only records older than the retention window" do
    now = Time.zone.parse("2026-04-02 12:00:00")
    old_visit = create_ahoy_visit(started_at: now - 400.days, visitor_token: "visitor-old")
    recent_visit = create_ahoy_visit(started_at: now - 5.days, visitor_token: "visitor-new")
    create_ahoy_event(visit: old_visit, name: "Viewed blog post", time: now - 400.days)
    create_ahoy_event(visit: recent_visit, name: "Started chat", time: now - 5.days)

    result = Analytics::AhoyPruner.new(days: 365, now: now).call

    assert_equal 1, result[:visits_deleted]
    assert_equal 1, result[:events_deleted]
    assert_equal [recent_visit.id], Ahoy::Visit.order(:started_at).pluck(:id)
    assert_equal ["Started chat"], Ahoy::Event.order(:time).pluck(:name)
  end
end
