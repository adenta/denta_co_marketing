require "test_helper"

class BlogSubscriptionsMailerTest < ActionMailer::TestCase
  include Rails.application.routes.url_helpers

  test "confirmation includes the translated subject and confirmation link" do
    subscription = BlogSubscription.create!(email_address: "reader@example.com")

    email = BlogSubscriptionsMailer.confirmation(subscription)

    assert_equal [ "reader@example.com" ], email.to
    assert_equal I18n.t("mailers.blog_subscriptions.confirmation.subject"), email.subject
    assert_match %r{http://example.com/blog_subscription/confirm\?token=}, email.body.encoded
  end
end
