xml.instruct! :xml, version: "1.0", encoding: "UTF-8"

xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  xml.url do
    xml.loc absolute_page_url(root_path)
    xml.lastmod @latest_publication_date.iso8601 if @latest_publication_date.present?
    xml.changefreq "weekly"
    xml.priority "1.0"
  end

  xml.url do
    xml.loc absolute_page_url(blog_posts_path)
    xml.lastmod @latest_publication_date.iso8601 if @latest_publication_date.present?
    xml.changefreq "weekly"
    xml.priority "0.8"
  end

  @posts.each do |post|
    xml.url do
      xml.loc absolute_page_url(content_post_path(post.slug))
      xml.lastmod post.published_on.iso8601
      xml.changefreq "monthly"
      xml.priority "0.7"
    end
  end
end
