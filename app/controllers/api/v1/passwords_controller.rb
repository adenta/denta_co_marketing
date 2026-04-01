module Api
  module V1
    class PasswordsController < ApplicationController
      NOT_IMPLEMENTED_MESSAGE = "Password reset is not available for this application.".freeze

      def create
        render_not_implemented
      end

      def update
        render_not_implemented
      end

      private
        def render_not_implemented
          render json: {
            message: NOT_IMPLEMENTED_MESSAGE
          }, status: :not_implemented
        end
    end
  end
end
