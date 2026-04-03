class HomeController < ApplicationController
  def index
    return unless cache_public_page!(
      etag: [ "home", I18n.locale ],
      last_modified: translations_last_updated_at,
    )

    @page_meta = {
      title: I18n.t("site.meta.default_title", default: "Andrew Denta"),
      description: "Base application shell with shared navigation and page mounts ready for a fresh content pass."
    }
    @props = {
      aboutPath: about_path,
      blogPath: blog_posts_path,
      projectsPath: projects_path,
      servicesPath: services_path
    }
  end

  private

  def current_nav_key
    "home"
  end
end
