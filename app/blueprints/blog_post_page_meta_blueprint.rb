class BlogPostPageMetaBlueprint < Blueprinter::Base
  DEFAULT_SOCIAL_IMAGE_PATH = "/andrew-denta-2026.jpeg".freeze

  field :title do |post, options|
    "#{post.title} | #{options.fetch(:site_title)}"
  end

  field :excerpt, name: :description

  field :canonical do |post|
    Rails.application.routes.url_helpers.blog_post_path(post.slug)
  end

  field :image do |_post|
    DEFAULT_SOCIAL_IMAGE_PATH
  end

  field :og_type do
    "article"
  end

  field :author

  field :published_on, name: :published_time

  field :structured_data do |post, options|
    [
      BlogPostStructuredDataBlueprint.render_as_hash(
        post,
        application_name: options.fetch(:application_name),
        base_url: options.fetch(:base_url),
        image_url: options.fetch(:image_url),
        locale: options.fetch(:locale),
      )
    ]
  end
end
