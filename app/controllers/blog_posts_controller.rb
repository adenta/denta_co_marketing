class BlogPostsController < ApplicationController
  allow_unauthenticated_access

  def index
    page_content = localized_copy("pages.blog.index")

    @page_meta = page_content.fetch(:meta)
    @page_content = page_content.except(:meta)
    @posts = repository.published_posts(include_drafts: preview_enabled?)
  end

  def show
    @post = repository.published_post_by_slug!(params[:slug], include_drafts: preview_enabled?)
  end

  private

  def repository
    @repository ||= Blog::PostRepository.new
  end

  def preview_enabled?
    Rails.env.development? || Rails.env.test?
  end
end
