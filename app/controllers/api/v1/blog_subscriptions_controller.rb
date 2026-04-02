module Api
  module V1
    class BlogSubscriptionsController < ApplicationController
      allow_unauthenticated_access only: :create

      def create
        BlogSubscriptions::UpsertFromWebForm.new(
          email_address: blog_subscription_params[:email_address],
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
        ).call

        render json: { message: I18n.t("blog_subscriptions.create.success") }
      rescue ActiveRecord::RecordInvalid => error
        render json: {
          message: I18n.t("blog_subscriptions.create.invalid"),
          errors: error.record.errors.to_hash(true),
        }, status: :unprocessable_entity
      end

      private
        def blog_subscription_params
          payload = params[:blog_subscription]
          payload = params unless payload.is_a?(ActionController::Parameters) && payload.present?
          payload.permit(:email_address)
        end
    end
  end
end
