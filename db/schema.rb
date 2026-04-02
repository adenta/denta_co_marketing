# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_04_02_164103) do
  create_table "action_mailbox_inbound_emails", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "message_checksum", null: false
    t.string "message_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "active_storage_attachments", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "blob_id", limit: 36, null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "record_id", limit: 36, null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "blob_id", limit: 36, null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "ahoy_events", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "name"
    t.text "properties"
    t.datetime "time"
    t.string "user_id", limit: 36
    t.string "visit_id", limit: 36
    t.index ["name", "time"], name: "index_ahoy_events_on_name_and_time"
    t.index ["user_id"], name: "index_ahoy_events_on_user_id"
    t.index ["visit_id"], name: "index_ahoy_events_on_visit_id"
  end

  create_table "ahoy_visits", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "app_version"
    t.string "browser"
    t.string "city"
    t.string "country"
    t.string "device_type"
    t.string "ip"
    t.text "landing_page"
    t.float "latitude"
    t.float "longitude"
    t.string "os"
    t.string "os_version"
    t.string "platform"
    t.text "referrer"
    t.string "referring_domain"
    t.string "region"
    t.datetime "started_at"
    t.text "user_agent"
    t.string "user_id", limit: 36
    t.string "utm_campaign"
    t.string "utm_content"
    t.string "utm_medium"
    t.string "utm_source"
    t.string "utm_term"
    t.string "visit_token"
    t.string "visitor_token"
    t.index ["user_id"], name: "index_ahoy_visits_on_user_id"
    t.index ["visit_token"], name: "index_ahoy_visits_on_visit_token", unique: true
    t.index ["visitor_token", "started_at"], name: "index_ahoy_visits_on_visitor_token_and_started_at"
  end

  create_table "blazer_audits", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.datetime "created_at"
    t.string "data_source"
    t.string "query_id", limit: 36
    t.text "statement"
    t.string "user_id", limit: 36
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "check_type"
    t.datetime "created_at", null: false
    t.string "creator_id", limit: 36
    t.text "emails"
    t.datetime "last_run_at"
    t.text "message"
    t.string "query_id", limit: 36
    t.string "schedule"
    t.text "slack_channels"
    t.string "state"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "dashboard_id", limit: 36
    t.integer "position"
    t.string "query_id", limit: 36
    t.datetime "updated_at", null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "creator_id", limit: 36
    t.string "name"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "creator_id", limit: 36
    t.string "data_source"
    t.text "description"
    t.string "name"
    t.text "statement"
    t.string "status"
    t.datetime "updated_at", null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "blog_subscriptions", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.integer "status", default: 0, null: false
    t.string "subscribe_ip_address"
    t.string "subscribe_user_agent"
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_blog_subscriptions_on_email_address", unique: true
    t.index ["status"], name: "index_blog_subscriptions_on_status"
  end

  create_table "chats", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.string "agent_type", default: "AssistantAgent", null: false
    t.string "chatable_id", limit: 36
    t.string "chatable_type"
    t.datetime "created_at", null: false
    t.string "model_id", limit: 36
    t.datetime "updated_at", null: false
    t.string "user_id", limit: 36, null: false
    t.index ["agent_type"], name: "index_chats_on_agent_type"
    t.index ["chatable_type", "chatable_id"], name: "index_chats_on_chatable_type_and_chatable_id", unique: true, where: "chatable_type IS NOT NULL AND chatable_id IS NOT NULL"
    t.index ["model_id"], name: "index_chats_on_model_id"
    t.index ["user_id"], name: "index_chats_on_user_id"
  end

  create_table "messages", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.integer "cache_creation_tokens"
    t.integer "cached_tokens"
    t.string "chat_id", limit: 36, null: false
    t.text "content"
    t.json "content_raw"
    t.datetime "created_at", null: false
    t.integer "input_tokens"
    t.string "model_id", limit: 36
    t.integer "output_tokens"
    t.string "role", null: false
    t.text "thinking_signature"
    t.text "thinking_text"
    t.integer "thinking_tokens"
    t.string "tool_call_id", limit: 36
    t.datetime "updated_at", null: false
    t.index ["chat_id"], name: "index_messages_on_chat_id"
    t.index ["model_id"], name: "index_messages_on_model_id"
    t.index ["role"], name: "index_messages_on_role"
    t.index ["tool_call_id"], name: "index_messages_on_tool_call_id"
  end

  create_table "models", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.json "capabilities", default: []
    t.integer "context_window"
    t.datetime "created_at", null: false
    t.string "family"
    t.date "knowledge_cutoff"
    t.integer "max_output_tokens"
    t.json "metadata", default: {}
    t.json "modalities", default: {}
    t.datetime "model_created_at"
    t.string "model_id", null: false
    t.string "name", null: false
    t.json "pricing", default: {}
    t.string "provider", null: false
    t.datetime "updated_at", null: false
    t.index ["family"], name: "index_models_on_family"
    t.index ["provider", "model_id"], name: "index_models_on_provider_and_model_id", unique: true
    t.index ["provider"], name: "index_models_on_provider"
  end

  create_table "sessions", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.string "user_id", limit: 36, null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "tool_calls", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.json "arguments", default: {}
    t.datetime "created_at", null: false
    t.string "message_id", limit: 36, null: false
    t.string "name", null: false
    t.string "thought_signature"
    t.string "tool_call_id", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id"], name: "index_tool_calls_on_message_id"
    t.index ["name"], name: "index_tool_calls_on_name"
    t.index ["tool_call_id"], name: "index_tool_calls_on_tool_call_id", unique: true
  end

  create_table "users", id: { type: :string, limit: 36 }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "chats", "models"
  add_foreign_key "chats", "users"
  add_foreign_key "messages", "chats"
  add_foreign_key "messages", "models"
  add_foreign_key "messages", "tool_calls"
  add_foreign_key "sessions", "users"
  add_foreign_key "tool_calls", "messages"
end
