require "test_helper"

class Api::V1::BlogSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "create stores a pending subscription and sends a confirmation email" do
    assert_emails 1 do
      post api_v1_blog_subscriptions_path, params: {
        email_address: " Reader@example.com "
      }, as: :json, headers: {
        "User-Agent" => "Blog Signup Test",
      }
    end

    assert_response :success
    assert_equal I18n.t("blog_subscriptions.create.success"), response.parsed_body["message"]

    subscription = BlogSubscription.find_by!(email_address: "reader@example.com")
    assert subscription.pending?
    assert_equal "127.0.0.1", subscription.subscribe_ip_address
    assert_equal "Blog Signup Test", subscription.subscribe_user_agent
    assert_not_nil subscription.confirmation_sent_at
  end

  test "create resends confirmation for an existing pending subscription" do
    subscription = BlogSubscription.create!(
      email_address: "reader@example.com",
      status: :pending,
      confirmation_sent_at: 2.days.ago,
      subscribe_ip_address: "10.0.0.1",
      subscribe_user_agent: "Before",
    )

    assert_emails 1 do
      post api_v1_blog_subscriptions_path, params: {
        email_address: "reader@example.com"
      }, as: :json, headers: {
        "User-Agent" => "Blog Signup Retry",
      }
    end

    assert_response :success
    assert_equal 1, BlogSubscription.count

    subscription.reload
    assert subscription.pending?
    assert subscription.confirmation_sent_at > 1.minute.ago
    assert_equal "127.0.0.1", subscription.subscribe_ip_address
    assert_equal "Blog Signup Retry", subscription.subscribe_user_agent
  end

  test "create does not resend confirmation for an active subscription" do
    BlogSubscription.create!(
      email_address: "reader@example.com",
      status: :active,
      confirmed_at: Time.current,
    )

    assert_emails 0 do
      post api_v1_blog_subscriptions_path, params: {
        email_address: "reader@example.com"
      }, as: :json
    end

    assert_response :success
    assert_equal 1, BlogSubscription.count
    assert BlogSubscription.find_by!(email_address: "reader@example.com").active?
  end

  test "create returns validation errors for an invalid email address" do
    assert_emails 0 do
      post api_v1_blog_subscriptions_path, params: {
        email_address: "not-an-email"
      }, as: :json
    end

    assert_response :unprocessable_entity
    assert_equal I18n.t("blog_subscriptions.create.invalid"), response.parsed_body["message"]
    assert_includes response.parsed_body.fetch("errors").fetch("email_address"), "Email address must be a valid email address"
  end
end
