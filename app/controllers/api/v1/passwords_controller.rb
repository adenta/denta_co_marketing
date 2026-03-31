module Api
  module V1
    class PasswordsController < ApplicationController
      allow_unauthenticated_access
      disallow_authenticated_api_access only: %i[ create update ]
      before_action :set_user_by_token, only: :update
      rate_limit to: 10, within: 3.minutes, only: :create, with: -> {
        render json: { message: "Try again later." }, status: :too_many_requests
      }

      def create
        if user = User.find_by(email_address: password_create_params[:email_address])
          PasswordsMailer.reset(user).deliver_later
        end

        flash[:notice] = "Password reset instructions sent (if user with that email address exists)."
        render json: { redirect_to: new_session_path }
      end

      def update
        if @user.update(password_params)
          @user.sessions.destroy_all
          flash[:notice] = "Password has been reset."
          render json: { redirect_to: new_session_path }
        else
          render json: {
            message: "Please correct the highlighted fields.",
            errors: @user.errors.to_hash(true)
          }, status: :unprocessable_entity
        end
      end

      private
        def password_create_params
          payload = params[:password]
          payload = params unless payload.is_a?(ActionController::Parameters) && payload.present?
          payload.permit(:email_address)
        end

        def password_params
          payload = params[:password]
          payload = params unless payload.is_a?(ActionController::Parameters) && payload.present?
          payload.permit(:password, :password_confirmation)
        end

        def set_user_by_token
          @user = User.find_by_password_reset_token!(params[:token])
        rescue ActiveSupport::MessageVerifier::InvalidSignature
          render json: {
            message: "Password reset link is invalid or has expired.",
            redirect_to: new_password_path
          }, status: :not_found
        end
    end
  end
end
