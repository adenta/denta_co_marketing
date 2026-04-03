class PagesController < ApplicationController
  allow_unauthenticated_access

  def about
    page_content = localized_copy("pages.about")

    @page_meta = page_content.fetch(:meta)
    @props = { content: page_content.except(:meta) }
  end

  def services
    page_content = localized_copy("pages.services")

    @page_meta = page_content.fetch(:meta)
    @props = { content: page_content.except(:meta) }
  end

  private

  def current_nav_key
    action_name
  end
end
