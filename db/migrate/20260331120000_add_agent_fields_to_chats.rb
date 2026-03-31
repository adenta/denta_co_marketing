class AddAgentFieldsToChats < ActiveRecord::Migration[8.1]
  def change
    add_column :chats, :agent_type, :string, null: false, default: "AssistantAgent"
    add_column :chats, :chatable_type, :string
    add_column :chats, :chatable_id, :string, limit: 36

    add_index :chats, :agent_type
    add_index :chats, [ :chatable_type, :chatable_id ],
      unique: true,
      where: "chatable_type IS NOT NULL AND chatable_id IS NOT NULL",
      name: "index_chats_on_chatable_type_and_chatable_id"
  end
end
