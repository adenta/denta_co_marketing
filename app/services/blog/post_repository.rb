require "yaml"
require "date"
require "digest"

module Blog
  class PostRepository
    class InvalidPostError < StandardError; end

    FRONTMATTER_PATTERN = /\A---\s*\n(?<frontmatter>.*?)\n---\s*\n?(?<body>.*)\z/m
    REQUIRED_FIELDS = %w[title excerpt published_on].freeze

    def initialize(
      root: Rails.root.join("content/blog"),
      renderer: Blog::MarkdownRenderer.new,
      cache: Rails.cache
    )
      @root = Pathname(root)
      @renderer = renderer
      @cache = cache
    end

    def published_posts(include_drafts: false)
      load_posts(include_drafts:)
    end

    def published_post_by_slug!(slug, include_drafts: false)
      post = load_post!(path_for(slug))
      raise ActiveRecord::RecordNotFound, "Blog post not found" if post.draft? && !include_drafts

      post
    end

    private

    def load_posts(include_drafts:)
      return [] unless @root.exist?

      @root.glob("*.md")
        .sort
        .map { |path| load_post!(path) }
        .reject { |post| post.draft? && !include_drafts }
        .sort_by(&:published_on)
        .reverse
    end

    def load_post!(path)
      raise ActiveRecord::RecordNotFound, "Blog post not found" unless path.exist?

      @cache.fetch(cache_key_for(path)) { build_post(path) }
    end

    def build_post(path)
      source = path.read
      match = FRONTMATTER_PATTERN.match(source)
      raise InvalidPostError, "Missing frontmatter in #{path.basename}" unless match

      metadata = YAML.safe_load(
        match[:frontmatter],
        permitted_classes: [ Date ],
        aliases: false
      ) || {}

      metadata = metadata.stringify_keys
      validate_metadata!(metadata, path)

      rendered = @renderer.render(match[:body])

      Blog::Post.new(
        slug: path.basename(".md").to_s,
        title: metadata.fetch("title").to_s,
        excerpt: metadata.fetch("excerpt").to_s,
        published_on: coerce_date(metadata.fetch("published_on"), path:),
        author: metadata["author"],
        tags: metadata["tags"],
        cover_image: metadata["cover_image"],
        html_body: rendered.html,
        reading_time_minutes: reading_time_for(match[:body]),
        headings: rendered.headings,
        draft: ActiveModel::Type::Boolean.new.cast(metadata["draft"])
      )
    end

    def validate_metadata!(metadata, path)
      missing_fields = REQUIRED_FIELDS.reject { |field| metadata[field].present? }
      return if missing_fields.empty?

      raise InvalidPostError, "Missing #{missing_fields.join(', ')} in #{path.basename}"
    end

    def coerce_date(value, path:)
      return value if value.is_a?(Date)

      Date.iso8601(value.to_s)
    rescue Date::Error
      raise InvalidPostError, "Invalid published_on in #{path.basename}"
    end

    def reading_time_for(markdown)
      word_count = markdown.to_s.scan(/\b[\p{Alnum}][\p{Alnum}'-]*\b/).size
      return 0 if word_count.zero?

      [(word_count / 200.0).ceil, 1].max
    end

    def path_for(slug)
      @root.join("#{slug}.md")
    end

    def cache_key_for(path)
      [
        "blog-post",
        Digest::SHA256.hexdigest(path.to_s),
        path.mtime.to_f,
        "v1"
      ]
    end
  end
end
