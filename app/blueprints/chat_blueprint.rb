class ChatBlueprint < Blueprinter::Base
  identifier :id

  field :agent_type

  field :display_name do |chat|
    chat.display_name
  end

  field :path do |chat|
    Rails.application.routes.url_helpers.chat_path(chat)
  end

  field :updated_at do |chat|
    chat.updated_at.iso8601
  end

  field :chatable_type do |chat|
    chat.chatable_type
  end

  field :chatable_id do |chat|
    chat.chatable_id
  end

  field :linked_resource do |chat|
    chat.linked_resource
  end

  view :detail do
  end
end
