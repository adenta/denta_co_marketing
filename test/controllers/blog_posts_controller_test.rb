require "test_helper"

class BlogPostsControllerTest < ActionDispatch::IntegrationTest
  test "blog index is publicly accessible and renders published posts" do
    get blog_posts_path

    assert_response :success
    assert_includes @response.body, "<title>Writing | Andrew Denta</title>"
    assert_includes @response.body, ">Writing</h1>"
    assert_includes @response.body, "Context Engineering Is Only Half the Battle"
    assert_includes @response.body, "Why scaffolds matter just as much as context engineering when you want reliable AI-assisted software delivery."
    assert_includes @response.body, content_post_path("context-engineering-is-only-half")
    refute_includes @response.body, "Add markdown files to publish the first post."
    assert_includes @response.body, '<html lang="en">'
    assert_includes @response.body, '<meta name="description" content="Writing.">'
    assert_includes @response.body, '<link rel="canonical" href="http://example.com/writing">'
    assert_includes @response.body, '<meta property="og:type" content="website">'
    assert_includes @response.body, '<meta property="og:url" content="http://example.com/writing">'
    assert_includes response.headers["Cache-Control"], "max-age=86400"
    assert_includes response.headers["Cache-Control"], "public"
    assert_includes @response.body, 'aria-label="Primary"'
    assert_includes @response.body, I18n.t("blog_subscriptions.card.title")
    assert_includes @response.body, "blog/BlogSubscribeForm"
  end
end
