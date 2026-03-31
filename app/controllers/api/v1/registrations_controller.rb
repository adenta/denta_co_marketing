module Api
  module V1
    class RegistrationsController < ApplicationController
      allow_unauthenticated_access only: :create
      disallow_authenticated_api_access only: :create

      def create
        user = User.new(registration_params)

        if user.save
          start_new_session_for user
          flash[:notice] = "Account created."
          render json: { redirect_to: after_authentication_url }
        else
          render json: {
            message: "Please correct the highlighted fields.",
            errors: user.errors.to_hash(true)
          }, status: :unprocessable_entity
        end
      end

      private
        def registration_params
          payload = params[:registration]
          payload = params unless payload.is_a?(ActionController::Parameters) && payload.present?
          payload.permit(:email_address, :password, :password_confirmation)
        end
    end
  end
end
