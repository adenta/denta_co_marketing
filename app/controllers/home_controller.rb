class HomeController < ApplicationController
  def index
    home_page_content = localized_copy("pages.home")
    recent_posts = repository.published_posts.first(3)

    return unless cache_public_page!(
      etag: [ "home", I18n.locale, recent_posts.map { |post| [ post.slug, post.source_updated_at&.to_i ] } ],
      last_modified: [ translations_last_updated_at, repository.latest_updated_at ].compact.max,
    )

    @page_meta = home_page_content.fetch(:meta)
    @props = {
      content: home_page_content.except(:meta),
      blog_index_path: blog_posts_path,
      recent_posts: PostBlueprint.render_as_hash(recent_posts)
    }
  end

  private

  def repository
    @repository ||= Blog::PostRepository.new
  end
end
