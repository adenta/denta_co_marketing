class Article
  attr_reader :slug, :title, :category, :published_on, :summary, :body

  def initialize(slug:, title:, category:, published_on:, summary:, body:)
    @slug = slug
    @title = title
    @category = category
    @published_on = published_on
    @summary = summary
    @body = body
  end

  def published_at
    published_on.strftime("%B %Y")
  end

  def path
    Rails.application.routes.url_helpers.article_path(slug)
  end
end
