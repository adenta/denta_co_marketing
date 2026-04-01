class SessionsController < ApplicationController
  disallow_authenticated_access only: :new

  def new
    @props = {
      create_path: api_v1_session_path
    }
  end
end
