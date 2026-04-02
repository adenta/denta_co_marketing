class CreateBlogSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_subscriptions, id: :uuid, if_not_exists: true do |t|
      t.string :email_address, null: false
      t.integer :status, null: false, default: 0
      t.datetime :confirmation_sent_at
      t.datetime :confirmed_at
      t.string :subscribe_ip_address
      t.string :subscribe_user_agent

      t.timestamps
    end

    add_index :blog_subscriptions, :email_address, unique: true, if_not_exists: true
    add_index :blog_subscriptions, :status, if_not_exists: true
  end
end
