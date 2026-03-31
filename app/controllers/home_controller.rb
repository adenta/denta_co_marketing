class HomeController < ApplicationController
  def index
    authorize Chat, :index?

    @props = {
      chats: ChatBlueprint.render_as_hash(chats),
      create_chat_path: api_v1_chats_path,
      available_agents: Chat.available_agents,
      default_agent_type: Chat.default_agent_type
    }
  end

  private

  def chats
    @chats ||= policy_scope(Chat).order(updated_at: :desc).to_a
  end
end
