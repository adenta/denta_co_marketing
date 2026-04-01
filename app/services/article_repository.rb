require "yaml"

class ArticleRepository
  CONTENT_ROOT = Rails.root.join("app/content/articles").freeze
  CACHE_NAMESPACE = "article_repository/v1".freeze
  FRONT_MATTER_PARSER = Content::FrontMatterParser.new
  MARKDOWN_RENDERER = Content::MarkdownRenderer.new
  METADATA_SCHEMA = Content::MetadataSchema.new(
    required: {
      "title" => :string,
      "category" => :string,
      "published_on" => :date,
      "summary" => :string
    }
  )

  class << self
    def all
      cached_articles
    end

    def recent(limit: 3)
      cached_articles.first(limit)
    end

    def find_by_slug(slug)
      cached_articles.find { |article| article.slug == slug }
    end

    private

    def cached_articles
      Rails.cache.fetch([ CACHE_NAMESPACE, content_fingerprint ]) do
        article_paths.map { |path| load_article(path) }.sort_by(&:published_on).reverse
      end
    end

    def content_fingerprint
      article_paths.map { |path| "#{path.basename}:#{path.mtime.to_i}" }.join("|")
    end

    def article_paths
      Dir[CONTENT_ROOT.join("*.md")].sort.map { |path| Pathname(path) }
    end

    def load_article(path)
      parsed = FRONT_MATTER_PARSER.parse(path.read, path:)
      metadata = METADATA_SCHEMA.validate!(parsed.metadata, path:)
      rendered = MARKDOWN_RENDERER.render(parsed.body)

      Article.new(
        slug: path.basename(".md").to_s,
        title: metadata.fetch("title"),
        category: metadata.fetch("category"),
        published_on: metadata.fetch("published_on"),
        summary: metadata.fetch("summary"),
        html_body: rendered.html,
        headings: rendered.headings
      )
    end
  end
end
