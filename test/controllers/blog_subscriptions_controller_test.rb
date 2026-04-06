require "test_helper"

class BlogSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "confirm activates a pending subscription" do
    subscription = BlogSubscription.create!(email_address: "reader@example.com")

    assert_difference('Ahoy::Event.where(name: "Confirmed blog subscription").count', 1) do
      get confirm_blog_subscription_path(token: subscription.confirmation_token)
    end

    assert_redirected_to writing_path
    assert_equal I18n.t("blog_subscriptions.confirm.success"), flash[:notice]
    assert subscription.reload.active?
    assert_not_nil subscription.confirmed_at

    event = Ahoy::Event.where(name: "Confirmed blog subscription").order(:time).last
    assert_equal "email_confirmation", event.properties["source"]
  end

  test "confirm rejects an invalid token" do
    get confirm_blog_subscription_path(token: "bad-token")

    assert_redirected_to writing_path
    assert_equal I18n.t("blog_subscriptions.confirm.invalid"), flash[:alert]
  end

  test "confirm does not retrack an already active subscription" do
    subscription = BlogSubscription.create!(
      email_address: "reader@example.com",
      status: :active,
      confirmed_at: Time.current,
    )

    assert_no_difference('Ahoy::Event.where(name: "Confirmed blog subscription").count') do
      get confirm_blog_subscription_path(token: subscription.confirmation_token)
    end

    assert_redirected_to writing_path
    assert_equal I18n.t("blog_subscriptions.confirm.success"), flash[:notice]
  end
end
