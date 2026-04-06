class BlogSubscriptionsController < ApplicationController
  allow_unauthenticated_access only: :confirm

  def confirm
    subscription = BlogSubscription.find_for_confirmation(params[:token])

    if subscription.nil?
      redirect_to writing_path, alert: I18n.t("blog_subscriptions.confirm.invalid")
      return
    end

    track_confirmation = subscription.pending?
    subscription.confirm!
    if track_confirmation
      ahoy.track("Confirmed blog subscription", source: "email_confirmation")
    end

    redirect_to writing_path, notice: I18n.t("blog_subscriptions.confirm.success")
  end
end
