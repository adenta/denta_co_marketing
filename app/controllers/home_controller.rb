class HomeController < ApplicationController
  def index
    @props = {
      recent_posts: PostBlueprint.render_as_hash(
        Blog::PostRepository.new.published_posts.first(3)
      )
    }
  end
end
