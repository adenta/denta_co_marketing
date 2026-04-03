require "test_helper"

class BlogPostsControllerTest < ActionDispatch::IntegrationTest
  test "blog index is publicly accessible and server renders published post content" do
    get blog_posts_path

    assert_response :success
    assert_includes @response.body, "<title>Writing | Andrew Denta</title>"
    assert_includes @response.body, "Long-form notes, essays, and project writeups live here when they exist."
    assert_includes @response.body, "The First Five Seconds Of Product Trust"
    assert_includes @response.body, "Notes On Shipping Before The Story Hardens"
    assert_includes @response.body, "What Survives After the AI Demo Ends"
    refute_includes @response.body, "Mangrove Technology Engagements"
    assert_includes @response.body, "Draft"
    assert_includes @response.body, '<html lang="en">'
    assert_includes @response.body, '<meta name="description" content="Writing archive and notes.">'
    assert_includes @response.body, '<link rel="canonical" href="http://example.com/blog">'
    assert_includes @response.body, '<meta property="og:type" content="website">'
    assert_includes @response.body, '<meta property="og:url" content="http://example.com/blog">'
    assert_includes response.headers["Cache-Control"], "max-age=86400"
    assert_includes response.headers["Cache-Control"], "public"
    assert_includes @response.body, "navigation/SiteNav"
    refute_includes @response.body, "navigation/Navbar"
    assert_includes @response.body, I18n.t("blog_subscriptions.card.title")
    assert_includes @response.body, "blog/BlogSubscribeForm"
  end
end
