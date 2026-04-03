require "test_helper"

class SeoControllerTest < ActionDispatch::IntegrationTest
  test "robots advertises the sitemap" do
    get robots_path

    assert_response :success
    assert_equal "text/plain", response.media_type
    assert_includes @response.body, "User-agent: *"
    assert_includes @response.body, "Allow: /"
    assert_includes @response.body, "Sitemap: http://example.com/sitemap.xml"
    assert_includes response.headers["Cache-Control"], "max-age=86400"
  end

  test "feed renders an atom feed with published posts" do
    get feed_path(format: :xml)

    assert_response :success
    assert_equal "application/atom+xml", response.media_type
    assert_includes @response.body, %(<feed xmlns="http://www.w3.org/2005/Atom">)
    assert_includes @response.body, %(<link href="http://example.com/feed.xml" rel="self" type="application/atom+xml"/>)
    assert_includes @response.body, "The First Five Seconds Of Product Trust"
    assert_includes @response.body, "http://example.com/blog/the-first-five-seconds-of-product-trust"
    assert_includes response.headers["Cache-Control"], "max-age=86400"
    refute_includes @response.body, "Notes On Shipping Before The Story Hardens"
  end

  test "sitemap renders public marketing and blog URLs" do
    get sitemap_path(format: :xml)

    assert_response :success
    assert_equal "application/xml", response.media_type
    assert_includes @response.body, %(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">)
    assert_includes @response.body, "<loc>http://example.com/</loc>"
    assert_includes @response.body, "<loc>http://example.com/blog</loc>"
    assert_includes @response.body, "<loc>http://example.com/blog/the-first-five-seconds-of-product-trust</loc>"
    assert_includes response.headers["Cache-Control"], "max-age=86400"
    refute_includes @response.body, "notes-on-shipping-before-the-story-hardens"
  end
end
