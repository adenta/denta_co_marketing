class HomeController < ApplicationController
  def index
    return unless cache_public_page!(
      etag: [ "home", I18n.locale ],
      last_modified: translations_last_updated_at,
    )

    @page_meta = {
      title: I18n.t("site.meta.default_title", default: "Andrew Denta"),
      description: "Application shell."
    }
  end

  private

  def current_nav_key
    "home"
  end
end
