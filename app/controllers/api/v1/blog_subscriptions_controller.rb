module Api
  module V1
    class BlogSubscriptionsController < ApplicationController
      allow_unauthenticated_access only: :create

      def create
        if turnstile_enabled?
          verification = BlogSubscriptions::TurnstileVerifier.new.verify(
            token: blog_subscription_params[:turnstile_token],
            remote_ip: request.remote_ip,
          )

          unless verification.success?
            return render_verification_error(verification)
          end
        end

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
          payload.permit(:email_address, :turnstile_token)
        end

        def render_verification_error(verification)
          if verification.configuration_error?
            render json: { message: verification.message }, status: :service_unavailable
          else
            render json: {
              message: verification.message,
              errors: { base: [ verification.message ] },
            }, status: :unprocessable_entity
          end
        end

        def turnstile_enabled?
          ENV["CLOUDFLARE_TURNSTILE_SITEKEY"].present? && ENV["CLOUDFLARE_TURNSTILE_SECRET_KEY"].present?
        end
    end
  end
end
