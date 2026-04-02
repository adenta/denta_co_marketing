class BlogSubscriptionsMailer < ApplicationMailer
  def confirmation(blog_subscription)
    @blog_subscription = blog_subscription

    mail(
      to: blog_subscription.email_address,
      subject: I18n.t("mailers.blog_subscriptions.confirmation.subject"),
    )
  end
end
