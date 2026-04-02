module BlogSubscriptions
  class UpsertFromWebForm
    def initialize(email_address:, ip_address:, user_agent:)
      @email_address = email_address
      @ip_address = ip_address
      @user_agent = user_agent
    end

    def call
      subscription = BlogSubscription.find_or_initialize_by(email_address:)
      return subscription if subscription.persisted? && subscription.active?

      subscription.assign_attributes(
        status: :pending,
        confirmed_at: nil,
        confirmation_sent_at: Time.current,
        subscribe_ip_address: ip_address,
        subscribe_user_agent: user_agent,
      )
      subscription.save!

      BlogSubscriptionsMailer.confirmation(subscription).deliver_now
      subscription
    end

    private
      attr_reader :email_address, :ip_address, :user_agent
  end
end
