module Api
  module V1
    class BlogSubscriptionsController < ApplicationController
      allow_unauthenticated_access only: :create

      def create
        verification = BlogSubscriptions::TurnstileVerifier.new.verify(
          token: blog_subscription_params[:turnstile_token],
          remote_ip: request.remote_ip,
        )

        unless verification.success?
          return render_verification_error(verification)
        end

        result = BlogSubscriptions::UpsertFromWebForm.new(
          email_address: blog_subscription_params[:email_address],
          ip_address: request.remote_ip,
          user_agent: request.user_agent,
        ).call
        track_subscription_request(result)

        render json: { message: I18n.t("blog_subscriptions.create.success") }
      rescue ActiveRecord::RecordInvalid => error
        render json: {
          message: I18n.t("blog_subscriptions.create.invalid"),
          errors: error.record.errors.to_hash(true),
        }, status: :unprocessable_entity
      end

      private
        def blog_subscription_params
          top_level_payload = params.permit(:email_address, :turnstile_token).to_h
          wrapped_payload = params.fetch(:blog_subscription, ActionController::Parameters.new)
            .permit(:email_address, :turnstile_token)
            .to_h

          ActionController::Parameters.new(top_level_payload.reverse_merge(wrapped_payload))
            .permit(:email_address, :turnstile_token)
        end

        def track_subscription_request(result)
          return unless result.confirmation_sent?

          ahoy.track(
            "Requested blog subscription",
            action: result.action,
            source: "blog_form",
          )
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
    end
  end
end
