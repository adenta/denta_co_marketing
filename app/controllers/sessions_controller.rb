class SessionsController < ApplicationController
  disallow_authenticated_access only: :new
  require_authenticated_access only: :destroy

  def new
    @page_meta = {
      title: "Sign in | #{I18n.t("site.meta.default_title", default: "Andrew Denta")}",
      description: "Use your email address and password to continue."
    }
    @props = {
      create_path: api_v1_session_path
    }
  end

  def destroy
    terminate_session
    redirect_to root_path, notice: "Signed out."
  end
end
