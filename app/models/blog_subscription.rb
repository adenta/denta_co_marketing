class BlogSubscription < ApplicationRecord
  CONFIRM_PURPOSE = :blog_subscription_confirmation
  CONFIRM_EXPIRATION = 14.days

  enum :status, {
    pending: 0,
    active: 1
  }, default: :pending

  normalizes :email_address, with: ->(value) { value.to_s.strip.downcase }

  validates :email_address, presence: true, uniqueness: true
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :status, presence: true

  def self.find_for_confirmation(token)
    find_signed(token, purpose: CONFIRM_PURPOSE)
  end

  def confirmation_token(expires_in: CONFIRM_EXPIRATION)
    signed_id(purpose: CONFIRM_PURPOSE, expires_in:)
  end

  def confirm!
    return if active?

    update!(
      status: :active,
      confirmed_at: Time.current,
    )
  end
end
