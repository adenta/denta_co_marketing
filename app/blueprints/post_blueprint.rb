class PostBlueprint < Blueprinter::Base
  identifier :slug

  field :path
  field :title
  field :author
  field :published_at
  field :excerpt
end
