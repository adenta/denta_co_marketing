class SessionsController < ApplicationController
  disallow_authenticated_access only: :new

  def new
    @page_meta = {
      title: "Sign in | #{I18n.t("site.meta.default_title", default: "Andrew Denta")}",
      description: "Use your email address and password to continue."
    }
    @props = {
      create_path: api_v1_session_path
    }
  end
end
