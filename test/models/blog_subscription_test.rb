require "test_helper"

class BlogSubscriptionTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    subscription = BlogSubscription.create!(email_address: " Reader@Example.com ")

    assert_equal "reader@example.com", subscription.email_address
  end

  test "requires a valid email address" do
    subscription = BlogSubscription.new(email_address: "not-an-email")

    assert_not subscription.valid?
    assert_includes subscription.errors.full_messages, "Email address must be a valid email address"
  end

  test "confirmation token resolves the record" do
    subscription = BlogSubscription.create!(email_address: "reader@example.com")

    assert_equal subscription, BlogSubscription.find_for_confirmation(subscription.confirmation_token)
  end

  test "confirm activates the subscription" do
    subscription = BlogSubscription.create!(email_address: "reader@example.com")

    subscription.confirm!

    assert subscription.active?
    assert_not_nil subscription.confirmed_at
  end
end
