class PostsController < ApplicationController
  allow_unauthenticated_access

  def show
    @post = repository.post_by_slug!(params[:slug], include_drafts: preview_enabled?)

    unless @post.project?
      ahoy.track "Viewed blog post", slug: @post.slug, title: @post.title
    end
  end

  private

  def current_nav_key
    @post&.project? ? "projects" : "blog"
  end

  def repository
    @repository ||= Blog::PostRepository.new
  end

  def preview_enabled?
    Rails.env.development? || Rails.env.test?
  end
end
