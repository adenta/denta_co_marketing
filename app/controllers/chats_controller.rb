class ChatsController < ApplicationController
  require_authenticated_access
  before_action :set_chat, only: [ :show ]

  def index
    authorize Chat, :index?

    @props = {
      chats: ChatBlueprint.render_as_hash(chats),
      create_chat_path: api_v1_chats_path,
      available_agents: Chat.available_agents,
      default_agent_type: Chat.default_agent_type
    }
  end

  def show
    authorize @chat
    @props = {
      chat: ChatBlueprint.render_as_hash(@chat, view: :detail),
      messages: MessageBlueprint.render_as_hash(messages)
    }
  end

  private

  def set_chat
    @chat = policy_scope(Chat).find(params[:id])
  end

  def chats
    @chats ||= policy_scope(Chat).order(updated_at: :desc).to_a
  end

  def messages
    # The chat transcript excludes internal tool/system rows, but assistant messages still
    # need preloaded tool_calls (+ their result messages) to render dynamic-tool parts
    # without N+1 queries.
    @messages ||= @chat.messages
      .where.not(role: [ "tool", "system" ])
      .includes(tool_calls: :result)
      .order(:created_at)
      .to_a
  end
end
