module Blog
  class Post
    attr_reader :slug, :title, :excerpt, :published_on, :author, :html_body, :source_updated_at

    def initialize(
      slug:,
      title:,
      excerpt:,
      published_on:,
      author: "Andrew Denta",
      html_body:,
      source_updated_at: nil,
      draft: false
    )
      @slug = slug
      @title = title
      @excerpt = excerpt
      @published_on = published_on
      @author = author.presence || "Andrew Denta"
      @html_body = html_body
      @source_updated_at = source_updated_at
      @draft = draft
    end

    def draft?
      @draft == true
    end

    def path
      Rails.application.routes.url_helpers.blog_post_path(slug)
    end

    def published_at
      published_on.strftime("%B %Y")
    end
  end
end
