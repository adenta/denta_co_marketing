xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

xml.feed xmlns: "http://www.w3.org/2005/Atom" do
  xml.id absolute_page_url(blog_posts_path)
  xml.title I18n.t("site.meta.default_title", default: "Andrew Denta")
  xml.subtitle "Writing archive and notes."
  xml.updated @feed_updated_at.iso8601
  xml.link href: absolute_page_url(feed_path(format: :xml)), rel: "self", type: "application/atom+xml"
  xml.link href: absolute_page_url(blog_posts_path)

  @posts.each do |post|
    post_url = absolute_page_url(content_post_path(post.slug))
    published_at = post.published_on.in_time_zone

    xml.entry do
      xml.id post_url
      xml.title post.title
      xml.link href: post_url
      xml.updated published_at.iso8601
      xml.published published_at.iso8601

      xml.author do
        xml.name post.author
      end

      xml.summary post.excerpt
      xml.content(type: "html") { xml.cdata! post.html_body }
    end
  end
end
