class ProjectsController < ApplicationController
  allow_unauthenticated_access

  def index
    @page_meta = {
      title: "Projects | #{I18n.t("site.meta.default_title", default: "Andrew Denta")}",
      description: "Project index scaffold with linked project entries."
    }
    @props = {
      projects: PostBlueprint.render_as_hash(
        repository.project_posts(include_drafts: preview_enabled?)
      )
    }
  end

  private

  def current_nav_key
    "projects"
  end

  def repository
    @repository ||= Blog::PostRepository.new
  end

  def preview_enabled?
    Rails.env.development? || Rails.env.test?
  end
end
