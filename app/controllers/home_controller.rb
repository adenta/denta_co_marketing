class HomeController < ApplicationController
  def index
    @props = {
      recent_articles: ArticleBlueprint.render_as_hash(ArticleRepository.recent)
    }
  end
end
