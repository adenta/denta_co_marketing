class SessionsController < ApplicationController
  disallow_authenticated_access only: :new

  def new
    page_content = localized_copy("pages.sessions.new")

    @page_meta = page_content.fetch(:meta)
    @props = {
      content: page_content.except(:meta),
      create_path: api_v1_session_path
    }
  end
end
