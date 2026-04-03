class PagesController < ApplicationController
  allow_unauthenticated_access

  def about
    @page_meta = {
      title: "About | #{I18n.t("site.meta.default_title", default: "Andrew Denta")}",
      description: "About page scaffold ready for a new narrative."
    }
  end

  def services
    @page_meta = {
      title: "Services | #{I18n.t("site.meta.default_title", default: "Andrew Denta")}",
      description: "Services page scaffold ready for a new offer structure."
    }
  end

  private

  def current_nav_key
    action_name
  end
end
