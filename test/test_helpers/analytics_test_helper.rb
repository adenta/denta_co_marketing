module AnalyticsTestHelper
  def create_ahoy_visit(started_at:, visitor_token:, visit_token: SecureRandom.uuid, user: nil, referring_domain: nil, landing_page: nil)
    Ahoy::Visit.create!(
      user: user,
      visit_token: visit_token,
      visitor_token: visitor_token,
      referring_domain: referring_domain,
      landing_page: landing_page || "https://example.com/",
      started_at: started_at,
    )
  end

  def create_ahoy_event(visit:, name:, time:, properties: {}, user: visit.user)
    Ahoy::Event.create!(
      visit: visit,
      user: user,
      name: name,
      properties: properties,
      time: time,
    )
  end
end

ActiveSupport.on_load(:active_support_test_case) do
  include AnalyticsTestHelper
end
