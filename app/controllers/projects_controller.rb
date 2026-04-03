class ProjectsController < ApplicationController
  allow_unauthenticated_access

  def index
    page_content = localized_copy("pages.projects")

    @page_meta = page_content.fetch(:meta)
    @props = {
      content: page_content.except(:meta),
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
