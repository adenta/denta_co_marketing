class User < ApplicationRecord
  has_secure_password
  has_many :chats, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :ahoy_visits, class_name: "Ahoy::Visit", dependent: :nullify
  has_many :ahoy_events, class_name: "Ahoy::Event", dependent: :nullify

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
end
