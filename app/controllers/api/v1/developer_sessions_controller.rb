module Api
  module V1
    class DeveloperSessionsController < ApplicationController
      disallow_authenticated_api_access only: :create

      def create
        unless Rails.env.development? || Rails.env.test?
          render json: {
            message: "Developer sign-in is only available in development and test environments.",
            redirect_to: new_session_path
          }, status: :forbidden
          return
        end

        user = User.order(:id).first || create_dev_user

        if user
          start_new_session_for user
          render json: {
            message: "Signed in as #{user.email_address}",
            redirect_to: root_url
          }
        else
          render json: {
            message: "Failed to create dev user."
          }, status: :unprocessable_entity
        end
      end

      private
        def create_dev_user
          User.find_or_create_by!(email_address: "dev@example.com") do |user|
            user.password = "password"
          end
        rescue ActiveRecord::RecordInvalid => error
          Rails.logger.error("Failed to create dev user: #{error.message}")
          nil
        end
    end
  end
end
