class BlogPostsController < ApplicationController
  allow_unauthenticated_access

  def index
    page_content = localized_copy("pages.blog.index")

    @page_meta = page_content.fetch(:meta)
    @page_content = page_content.except(:meta)
    @posts = repository.blog_posts(include_drafts: preview_enabled?)
  end

  private

  def current_nav_key
    "blog"
  end

  def repository
    @repository ||= Blog::PostRepository.new
  end

  def preview_enabled?
    Rails.env.development? || Rails.env.test?
  end
end
