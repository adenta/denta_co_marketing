class BlogSubscriptionsController < ApplicationController
  allow_unauthenticated_access only: :confirm

  def confirm
    subscription = BlogSubscription.find_for_confirmation(params[:token])

    if subscription.nil?
      redirect_to blog_posts_path, alert: I18n.t("blog_subscriptions.confirm.invalid")
      return
    end

    subscription.confirm!
    redirect_to blog_posts_path, notice: I18n.t("blog_subscriptions.confirm.success")
  end
end
