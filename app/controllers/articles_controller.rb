class ArticlesController < ApplicationController
  before_action :set_article, only: :show

  def show; end

  private

  def set_article
    @article = ArticleRepository.find_by_slug(params[:slug])
    raise ActionController::RoutingError, "Not Found" unless @article
  end
end
