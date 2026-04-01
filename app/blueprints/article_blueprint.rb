class ArticleBlueprint < Blueprinter::Base
  identifier :slug

  field :path
  field :title
  field :category
  field :published_at
  field :summary

  view :detail do
    field :html_body
    field :headings
  end
end
