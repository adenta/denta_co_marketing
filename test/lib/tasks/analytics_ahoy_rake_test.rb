require "test_helper"
require "rake"

class AnalyticsAhoyRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    Rake::Task["analytics:ahoy:summary"].reenable
    Rake::Task["analytics:ahoy:timeline"].reenable
    Rake::Task["analytics:ahoy:prune"].reenable
  end

  test "summary prints the expected sections" do
    visit = create_ahoy_visit(started_at: 1.day.ago, visitor_token: "visitor-1", referring_domain: "google.com")
    create_ahoy_event(visit: visit, name: "$view", time: 1.day.ago, properties: { "page" => "/" })
    create_ahoy_event(visit: visit, name: "Clicked contact CTA", time: 1.day.ago)

    output, = capture_io do
      Rake::Task["analytics:ahoy:summary"].invoke("7")
    end

    assert_includes output, "Ahoy summary: last 7 day(s)"
    assert_includes output, "Top pages:"
    assert_includes output, "/ (1)"
    assert_includes output, "Top custom events:"
    assert_includes output, "Clicked contact CTA (1)"
  end

  test "timeline prints daily counts" do
    visit = create_ahoy_visit(started_at: 1.day.ago, visitor_token: "visitor-1")
    create_ahoy_event(visit: visit, name: "$view", time: 1.day.ago, properties: { "page" => "/" })

    output, = capture_io do
      Rake::Task["analytics:ahoy:timeline"].invoke("2")
    end

    assert_includes output, "Ahoy timeline: last 2 day(s)"
    assert_includes output, (Date.current - 1.day).iso8601
  end

  test "prune deletes old data and prints counts" do
    visit = create_ahoy_visit(started_at: 400.days.ago, visitor_token: "visitor-1")
    create_ahoy_event(visit: visit, name: "Viewed blog post", time: 400.days.ago)

    output, = capture_io do
      Rake::Task["analytics:ahoy:prune"].invoke("365")
    end

    assert_includes output, "Visits deleted: 1"
    assert_includes output, "Events deleted: 1"
  end
end
