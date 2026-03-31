module Api
  module V1
    class ChatsController < ApplicationController
      def create
        authorize Chat, :create?

        agent_class = Chat.resolve_agent_class(agent_type_param)
        return render_invalid_agent_type unless agent_class

        chat = agent_class.create!(
          user: Current.user,
          agent_type: agent_class.name
        )

        render json: { id: chat.id, redirect_to: chat_path(chat) }
      end

      private

      def agent_type_param
        params[:agent_type].presence || Chat.default_agent_type
      end

      def render_invalid_agent_type
        render json: { message: "Invalid agent type." }, status: :unprocessable_entity
      end
    end
  end
end
