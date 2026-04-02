require "test_helper"

class Analytics::AhoyReportTest < ActiveSupport::TestCase
  test "summary aggregates visits, pages, referrers, and custom events" do
    now = Time.zone.parse("2026-04-02 12:00:00")
    user = users(:one)
    recent_visit = create_ahoy_visit(
      started_at: 1.day.ago,
      visitor_token: "visitor-1",
      user: user,
      referring_domain: "google.com",
      landing_page: "https://example.com/",
    )
    second_visit = create_ahoy_visit(
      started_at: 2.days.ago,
      visitor_token: "visitor-2",
      user: user,
      referring_domain: nil,
      landing_page: "https://example.com/blog/why-dental-practices-lose-leads",
    )
    create_ahoy_visit(
      started_at: 10.days.ago,
      visitor_token: "visitor-old",
      user: user,
      referring_domain: "news.ycombinator.com",
    )

    create_ahoy_event(
      visit: recent_visit,
      name: "$view",
      time: 1.day.ago,
      properties: { "page" => "/" },
      user: user,
    )
    create_ahoy_event(
      visit: recent_visit,
      name: "Clicked contact CTA",
      time: 1.day.ago,
      properties: { "location" => "home hero" },
      user: user,
    )
    create_ahoy_event(
      visit: second_visit,
      name: "$view",
      time: 2.days.ago,
      properties: { "page" => "/blog/why-dental-practices-lose-leads" },
      user: user,
    )
    create_ahoy_event(
      visit: second_visit,
      name: "Viewed blog post",
      time: 2.days.ago,
      properties: { "slug" => "why-dental-practices-lose-leads" },
      user: user,
    )
    create_ahoy_event(
      visit: second_visit,
      name: "Started chat",
      time: 10.days.ago,
      properties: { "chat_id" => "old-chat" },
      user: user,
    )

    summary = Analytics::AhoyReport.new(days: 7, now: now).summary

    assert_equal 2, summary[:visits]
    assert_equal 2, summary[:unique_visitors]
    assert_equal 4, summary[:events]
    assert_equal 2, summary[:page_views]
    assert_equal({ value: "/", count: 1 }, summary[:top_pages].first)
    assert_equal ["(direct)", "google.com"], summary[:top_referrers].map { |row| row[:value] }.sort
    assert_equal(
      [
        { value: "Clicked contact CTA", count: 1 },
        { value: "Viewed blog post", count: 1 },
      ],
      summary[:top_events],
    )
  end

  test "timeline includes zero-count days in the window" do
    now = Time.zone.parse("2026-04-02 12:00:00")
    visit = create_ahoy_visit(started_at: now - 1.day, visitor_token: "visitor-1")
    create_ahoy_event(visit: visit, name: "$view", time: now - 1.day, properties: { "page" => "/" })

    timeline = Analytics::AhoyReport.new(days: 2, now: now).timeline

    assert_equal 3, timeline.size
    assert_equal now.to_date - 2.days, timeline.first[:date]
    assert_equal 0, timeline.first[:visits]
    assert_equal 1, timeline.second[:visits]
    assert_equal 1, timeline.second[:views]
    assert_equal 1, timeline.second[:events]
    assert_equal 0, timeline.last[:events]
  end
end
