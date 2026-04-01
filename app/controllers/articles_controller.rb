class ArticlesController < ApplicationController
  before_action :set_article, only: :show

  def show
    @props = {
      article: ArticleBlueprint.render_as_hash(@article, view: :detail)
    }
  end

  private

  def set_article
    @article = ArticleRepository.find_by_slug(params[:slug])
    raise ActionController::RoutingError, "Not Found" unless @article
  end
end
