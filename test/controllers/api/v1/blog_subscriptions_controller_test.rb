require "test_helper"

class Api::V1::BlogSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  setup do
    ActionMailer::Base.deliveries.clear
  end

  test "create verifies using the top-level turnstile token from a json request" do
    test_case = self
    verifier = Object.new.tap do |instance|
      instance.define_singleton_method(:verify) do |token:, remote_ip:|
        test_case.assert_equal "valid-token", token
        test_case.assert_equal "127.0.0.1", remote_ip

        BlogSubscriptions::TurnstileVerifier::Result.new(success: true)
      end
    end

    with_stubbed_singleton_method(BlogSubscriptions::TurnstileVerifier, :new, -> { verifier }) do
      post api_v1_blog_subscriptions_path, params: {
        email_address: "reader@example.com",
        turnstile_token: "valid-token",
      }, as: :json
    end

    assert_response :success
  end

  test "create stores a pending subscription and sends a confirmation email" do
    verifier = verifier_for(BlogSubscriptions::TurnstileVerifier::Result.new(success: true))

    with_stubbed_singleton_method(BlogSubscriptions::TurnstileVerifier, :new, -> { verifier }) do
      assert_emails 1 do
        assert_difference('Ahoy::Event.where(name: "Requested blog subscription").count', 1) do
          post api_v1_blog_subscriptions_path, params: {
            email_address: " Reader@example.com ",
            turnstile_token: "valid-token",
          }, as: :json, headers: {
            "User-Agent" => "Blog Signup Test",
          }
        end
      end
    end

    assert_response :success
    assert_equal I18n.t("blog_subscriptions.create.success"), response.parsed_body["message"]

    subscription = BlogSubscription.find_by!(email_address: "reader@example.com")
    assert subscription.pending?
    assert_equal "127.0.0.1", subscription.subscribe_ip_address
    assert_equal "Blog Signup Test", subscription.subscribe_user_agent
    assert_not_nil subscription.confirmation_sent_at

    event = Ahoy::Event.where(name: "Requested blog subscription").order(:time).last
    assert_equal "created", event.properties["action"]
    assert_equal "blog_form", event.properties["source"]
  end

  test "create resends confirmation for an existing pending subscription" do
    verifier = verifier_for(BlogSubscriptions::TurnstileVerifier::Result.new(success: true))
    subscription = BlogSubscription.create!(
      email_address: "reader@example.com",
      status: :pending,
      confirmation_sent_at: 2.days.ago,
      subscribe_ip_address: "10.0.0.1",
      subscribe_user_agent: "Before",
    )

    with_stubbed_singleton_method(BlogSubscriptions::TurnstileVerifier, :new, -> { verifier }) do
      assert_emails 1 do
        assert_difference('Ahoy::Event.where(name: "Requested blog subscription").count', 1) do
          post api_v1_blog_subscriptions_path, params: {
            email_address: "reader@example.com",
            turnstile_token: "valid-token",
          }, as: :json, headers: {
            "User-Agent" => "Blog Signup Retry",
          }
        end
      end
    end

    assert_response :success
    assert_equal 1, BlogSubscription.count

    subscription.reload
    assert subscription.pending?
    assert subscription.confirmation_sent_at > 1.minute.ago
    assert_equal "127.0.0.1", subscription.subscribe_ip_address
    assert_equal "Blog Signup Retry", subscription.subscribe_user_agent

    event = Ahoy::Event.where(name: "Requested blog subscription").order(:time).last
    assert_equal "resent_confirmation", event.properties["action"]
    assert_equal "blog_form", event.properties["source"]
  end

  test "create does not resend confirmation for an active subscription" do
    verifier = verifier_for(BlogSubscriptions::TurnstileVerifier::Result.new(success: true))
    BlogSubscription.create!(
      email_address: "reader@example.com",
      status: :active,
      confirmed_at: Time.current,
    )

    with_stubbed_singleton_method(BlogSubscriptions::TurnstileVerifier, :new, -> { verifier }) do
      assert_emails 0 do
        assert_no_difference('Ahoy::Event.where(name: "Requested blog subscription").count') do
          post api_v1_blog_subscriptions_path, params: {
            email_address: "reader@example.com",
            turnstile_token: "valid-token",
          }, as: :json
        end
      end
    end

    assert_response :success
    assert_equal 1, BlogSubscription.count
    assert BlogSubscription.find_by!(email_address: "reader@example.com").active?
  end

  test "create returns validation errors for an invalid email address" do
    verifier = verifier_for(BlogSubscriptions::TurnstileVerifier::Result.new(success: true))

    with_stubbed_singleton_method(BlogSubscriptions::TurnstileVerifier, :new, -> { verifier }) do
      assert_emails 0 do
        post api_v1_blog_subscriptions_path, params: {
          email_address: "not-an-email",
          turnstile_token: "valid-token",
        }, as: :json
      end
    end

    assert_response :unprocessable_entity
    assert_equal I18n.t("blog_subscriptions.create.invalid"), response.parsed_body["message"]
    assert_includes response.parsed_body.fetch("errors").fetch("email_address"), "Email address must be a valid email address"
  end

  test "create rejects an invalid verification challenge" do
    verifier = verifier_for(
      BlogSubscriptions::TurnstileVerifier::Result.new(
        success: false,
        message: I18n.t("blog_subscriptions.create.verification_invalid"),
        error_code: :invalid_token,
      ),
    )

    with_stubbed_singleton_method(BlogSubscriptions::TurnstileVerifier, :new, -> { verifier }) do
      assert_emails 0 do
        post api_v1_blog_subscriptions_path, params: {
          email_address: "reader@example.com",
          turnstile_token: "bad-token",
        }, as: :json
      end
    end

    assert_response :unprocessable_entity
    assert_equal I18n.t("blog_subscriptions.create.verification_invalid"), response.parsed_body["message"]
    assert_equal [ I18n.t("blog_subscriptions.create.verification_invalid") ], response.parsed_body.dig("errors", "base")
    assert_equal 0, BlogSubscription.count
  end

  test "create returns service unavailable when turnstile is not configured" do
    verifier = verifier_for(
      BlogSubscriptions::TurnstileVerifier::Result.new(
        success: false,
        message: I18n.t("blog_subscriptions.create.unavailable"),
        error_code: :configuration,
      ),
    )

    with_stubbed_singleton_method(BlogSubscriptions::TurnstileVerifier, :new, -> { verifier }) do
      post api_v1_blog_subscriptions_path, params: {
        email_address: "reader@example.com",
        turnstile_token: "token",
      }, as: :json
    end

    assert_response :service_unavailable
    assert_equal I18n.t("blog_subscriptions.create.unavailable"), response.parsed_body["message"]
  end

  private
    def verifier_for(result)
      Object.new.tap do |verifier|
        verifier.define_singleton_method(:verify) { |**_kwargs| result }
      end
    end
end
