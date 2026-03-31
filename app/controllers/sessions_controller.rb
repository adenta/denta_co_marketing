class SessionsController < ApplicationController
  allow_unauthenticated_access only: :new
  disallow_authenticated_access only: :new

  def new
    @props = {
      create_path: api_v1_session_path,
      forgot_password_path: new_password_path,
      sign_up_path: new_registration_path
    }
  end
end
