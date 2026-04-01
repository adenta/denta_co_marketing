module Blog
  class Post
    attr_reader :slug, :title, :excerpt, :published_on, :author, :tags, :cover_image,
      :html_body, :reading_time_minutes, :headings

    def initialize(
      slug:,
      title:,
      excerpt:,
      published_on:,
      author: "Andrew Denta",
      tags: [],
      cover_image: nil,
      html_body:,
      reading_time_minutes:,
      headings: [],
      draft: false
    )
      @slug = slug
      @title = title
      @excerpt = excerpt
      @published_on = published_on
      @author = author.presence || "Andrew Denta"
      @tags = Array(tags).map(&:to_s).freeze
      @cover_image = cover_image.presence
      @html_body = html_body
      @reading_time_minutes = reading_time_minutes
      @headings = Array(headings).map { |heading| heading.stringify_keys.freeze }.freeze
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
