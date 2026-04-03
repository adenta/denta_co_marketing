class HomeController < ApplicationController
  def index
    home_page_content = localized_copy("pages.home")

    @page_meta = home_page_content.fetch(:meta)
    @props = {
      content: home_page_content.except(:meta),
      blog_index_path: blog_posts_path,
      recent_posts: PostBlueprint.render_as_hash(
        repository.blog_posts.first(3)
      )
    }
  end

  private

  def current_nav_key
    "home"
  end

  def repository
    @repository ||= Blog::PostRepository.new
  end
end
