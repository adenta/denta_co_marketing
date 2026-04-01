class Article
  attr_reader :slug, :title, :category, :published_on, :summary, :html_body, :headings

  def initialize(slug:, title:, category:, published_on:, summary:, html_body:, headings: [])
    @slug = slug
    @title = title
    @category = category
    @published_on = published_on
    @summary = summary
    @html_body = html_body
    @headings = Array(headings).map { |heading| heading.stringify_keys.freeze }.freeze
  end

  def published_at
    published_on.strftime("%B %Y")
  end

  def path
    Rails.application.routes.url_helpers.article_path(slug)
  end
end
