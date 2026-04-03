require "yaml"
require "date"
require "digest"

module Blog
  class PostRepository
    class InvalidPostError < StandardError; end

    METADATA_SCHEMA = Content::MetadataSchema.new(
      required: {
        "title" => :string,
        "excerpt" => :string,
        "published_on" => :date
      },
      optional: {
        "author" => :string,
        "draft" => :boolean,
        "tags" => :string_array
      }
    )

    def initialize(
      root: Rails.root.join("content/blog"),
      renderer: Content::MarkdownRenderer.new,
      cache: Rails.cache,
      front_matter_parser: Content::FrontMatterParser.new,
      metadata_schema: METADATA_SCHEMA
    )
      @root = Pathname(root)
      @renderer = renderer
      @cache = cache
      @front_matter_parser = front_matter_parser
      @metadata_schema = metadata_schema
    end

    def published_posts(include_drafts: false)
      load_posts(include_drafts:)
    end

    def blog_posts(include_drafts: false)
      published_posts(include_drafts:).reject(&:project?)
    end

    def project_posts(include_drafts: false)
      published_posts(include_drafts:).select(&:project?)
    end

    def post_by_slug!(slug, include_drafts: false)
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
      parsed = @front_matter_parser.parse(path.read, path:)
      metadata = @metadata_schema.validate!(parsed.metadata, path:)
      rendered = @renderer.render(parsed.body)

      Blog::Post.new(
        slug: path.basename(".md").to_s,
        title: metadata.fetch("title").to_s,
        excerpt: metadata.fetch("excerpt").to_s,
        published_on: metadata.fetch("published_on"),
        author: metadata["author"],
        html_body: rendered.html,
        draft: metadata["draft"],
        tags: metadata["tags"]
      )
    rescue Content::FrontMatterParser::ParseError, Content::MetadataSchema::ValidationError, Content::MarkdownRenderer::ShortcodeError => error
      raise InvalidPostError, error.message
    end

    def path_for(slug)
      @root.join("#{slug}.md")
    end

    def cache_key_for(path)
      [
        "blog-post",
        Digest::SHA256.hexdigest(path.to_s),
        path.mtime.to_f,
        "v4"
      ]
    end
  end
end
