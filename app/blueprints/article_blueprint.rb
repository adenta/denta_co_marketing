class ArticleBlueprint < Blueprinter::Base
  identifier :slug

  field :path
  field :title
  field :category
  field :published_at
  field :summary

  view :detail do
    field :body
  end
end
