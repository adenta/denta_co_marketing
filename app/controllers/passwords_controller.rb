class PasswordsController < ApplicationController
  allow_unauthenticated_access
  disallow_authenticated_access only: %i[ new edit ]
  before_action :set_user_by_token, only: :edit

  def new
    @props = {
      create_path: api_v1_passwords_path,
      sign_in_path: new_session_path
    }
  end

  def edit
    @props = {
      update_path: api_v1_password_path(params[:token]),
      sign_in_path: new_session_path
    }
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: "Password reset link is invalid or has expired."
    end
end
