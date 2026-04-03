class DeveloperSessionsController < ApplicationController
  disallow_authenticated_access only: :create

  def create
    unless Rails.env.development? || Rails.env.test?
      redirect_to new_session_path, alert: "Developer sign-in is only available in development and test environments."
      return
    end

    user = User.order(:id).first || create_dev_user

    if user
      start_new_session_for(user)
      redirect_to root_path, notice: "Signed in as #{user.email_address}"
    else
      redirect_to root_path, alert: "Failed to create dev user."
    end
  end

  private

  def create_dev_user
    User.find_or_create_by!(email_address: "dev@example.com") do |user|
      user.password = "password"
    end
  rescue ActiveRecord::RecordInvalid => error
    Rails.logger.error("Failed to create dev user: #{error.message}")
    nil
  end
end
