class AddUserToChats < ActiveRecord::Migration[8.1]
  def up
    clear_existing_chat_data

    add_reference :chats, :user, null: false, foreign_key: true, type: :uuid
  end

  def down
    remove_reference :chats, :user, foreign_key: true, type: :uuid
  end

  private

  def clear_existing_chat_data
    execute "DELETE FROM messages WHERE tool_call_id IS NOT NULL"
    execute "DELETE FROM tool_calls"
    execute "DELETE FROM messages"
    execute "DELETE FROM chats"
  end
end
