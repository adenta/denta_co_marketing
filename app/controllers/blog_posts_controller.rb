class BlogPostsController < ApplicationController
  allow_unauthenticated_access

  def index
    page_content = localized_copy("pages.blog.index")
    @posts = repository.blog_posts(include_drafts: preview_enabled?)

    return unless cache_public_page!(
      etag: [ "blog-index", I18n.locale, preview_enabled?, @posts.map { |post| [ post.slug, post.source_updated_at&.to_i ] } ],
      last_modified: [ translations_last_updated_at, repository.latest_updated_at(include_drafts: preview_enabled?) ].compact.max,
    )

    @page_meta = page_content.fetch(:meta)
    @page_content = page_content.except(:meta)
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
