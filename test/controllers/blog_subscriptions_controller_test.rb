require "test_helper"

class BlogSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "confirm activates a pending subscription" do
    subscription = BlogSubscription.create!(email_address: "reader@example.com")

    get confirm_blog_subscription_path(token: subscription.confirmation_token)

    assert_redirected_to blog_posts_path
    assert_equal I18n.t("blog_subscriptions.confirm.success"), flash[:notice]
    assert subscription.reload.active?
    assert_not_nil subscription.confirmed_at
  end

  test "confirm rejects an invalid token" do
    get confirm_blog_subscription_path(token: "bad-token")

    assert_redirected_to blog_posts_path
    assert_equal I18n.t("blog_subscriptions.confirm.invalid"), flash[:alert]
  end
end
