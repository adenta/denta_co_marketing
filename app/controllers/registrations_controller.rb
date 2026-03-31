class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: :new
  disallow_authenticated_access only: :new

  def new
    @props = {
      create_path: api_v1_registration_path,
      sign_in_path: new_session_path
    }
  end
end
