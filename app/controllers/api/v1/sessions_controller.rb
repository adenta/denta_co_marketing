module Api
  module V1
    class SessionsController < ApplicationController
      allow_unauthenticated_access only: :create
      disallow_authenticated_api_access only: :create
      rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
        render json: { message: "Try again later." }, status: :too_many_requests
      }

      def create
        if user = authenticated_user
          start_new_session_for user
          render json: { redirect_to: after_authentication_url }
        else
          render json: {
            message: "Try another email address or password.",
            errors: { base: [ "Try another email address or password." ] }
          }, status: :unprocessable_entity
        end
      end

      def destroy
        terminate_session
        flash[:notice] = "Signed out."
        render json: { redirect_to: new_session_path }
      end

      private
        def authenticated_user
          user = User.find_by(email_address: session_credentials[:email_address])
          user&.authenticate(session_credentials[:password])
        end

        def session_credentials
          payload = params[:session]
          payload = params unless payload.is_a?(ActionController::Parameters) && payload.present?

          {
            email_address: payload[:email_address],
            password: payload[:password]
          }
        end
    end
  end
end
