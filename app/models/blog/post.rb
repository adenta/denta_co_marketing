module Blog
  class Post
    attr_reader :slug, :title, :excerpt, :published_on, :author, :html_body, :source_updated_at, :tags

    def initialize(
      slug:,
      title:,
      excerpt:,
      published_on:,
      author: "Andrew Denta",
      html_body:,
      source_updated_at: nil,
      draft: false,
      tags: []
    )
      @slug = slug
      @title = title
      @excerpt = excerpt
      @published_on = published_on
      @author = author.presence || "Andrew Denta"
      @html_body = html_body
      @source_updated_at = source_updated_at
      @draft = draft
      @tags = Array(tags).map(&:to_s).uniq.freeze
    end

    def draft?
      @draft == true
    end

    def project?
      tags.include?("project")
    end

    def path
      Rails.application.routes.url_helpers.content_post_path(slug)
    end

    def published_at
      published_on.strftime("%B %Y")
    end
  end
end
