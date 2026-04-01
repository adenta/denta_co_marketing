require "yaml"

class ArticleRepository
  CONTENT_ROOT = Rails.root.join("app/content/articles").freeze
  CACHE_NAMESPACE = "article_repository/v1".freeze

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
      front_matter, body = parse_file(path)

      raw_published_on = front_matter.fetch("published_on")
      published_on = raw_published_on.is_a?(Date) ? raw_published_on : Date.parse(raw_published_on)
      paragraphs = body.split(/\n{2,}/).map(&:strip).reject(&:empty?)

      Article.new(
        slug: path.basename(".md").to_s,
        title: front_matter.fetch("title"),
        category: front_matter.fetch("category"),
        published_on: published_on,
        summary: front_matter.fetch("summary"),
        body: paragraphs
      )
    end

    def parse_file(path)
      raw = path.read
      match = raw.match(/\A---\s*\n(?<front_matter>.*?)\n---\s*\n(?<body>.*)\z/m)
      raise "Article file #{path} is missing YAML front matter" unless match

      front_matter = YAML.safe_load(match[:front_matter], permitted_classes: [ Date ]) || {}
      [ front_matter, match[:body] ]
    end
  end
end
