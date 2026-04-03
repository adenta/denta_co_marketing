class BlogPostStructuredDataBlueprint < Blueprinter::Base
  field :context, name: :"@context" do
    "https://schema.org"
  end

  field :type, name: :"@type" do
    "BlogPosting"
  end

  field :title, name: :headline
  field :excerpt, name: :description

  field :url do |post, options|
    URI.join(options.fetch(:base_url), Rails.application.routes.url_helpers.content_post_path(post.slug)).to_s
  end

  field :main_entity_of_page, name: :mainEntityOfPage do |post, options|
    post_url = URI.join(options.fetch(:base_url), Rails.application.routes.url_helpers.content_post_path(post.slug)).to_s

    {
      "@type" => "WebPage",
      "@id" => post_url
    }
  end

  field :published_on, name: :datePublished do |post|
    post.published_on.iso8601
  end

  field :source_updated_at, name: :dateModified do |post|
    (post.source_updated_at || post.published_on).iso8601
  end

  field :author do |post|
    {
      "@type" => "Person",
      "name" => post.author
    }
  end

  field :publisher do |_post, options|
    {
      "@type" => "Person",
      "name" => options.fetch(:application_name)
    }
  end

  field :image do |_post, options|
    [
      options.fetch(:image_url)
    ]
  end

  field :in_language, name: :inLanguage do |_post, options|
    options.fetch(:locale).to_s
  end
end
