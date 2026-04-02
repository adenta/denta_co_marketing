class HomeController < ApplicationController
  def index
    home_page_content = localized_copy("pages.home")

    @page_meta = home_page_content.fetch(:meta)
    @props = {
      content: home_page_content.except(:meta),
      recent_posts: PostBlueprint.render_as_hash(
        Blog::PostRepository.new.published_posts.first(3)
      )
    }
  end
end
