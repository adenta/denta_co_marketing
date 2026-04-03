require "test_helper"

class BlogPostsControllerTest < ActionDispatch::IntegrationTest
  test "blog index is publicly accessible and server renders published post content" do
    get blog_posts_path

    assert_response :success
    assert_includes @response.body, "<title>Writing | Andrew Denta</title>"
    assert_includes @response.body, "Writing on AI, software, and the systems that make ambitious work feel calmer."
    assert_includes @response.body, "The First Five Seconds Of Product Trust"
    assert_includes @response.body, "Notes On Shipping Before The Story Hardens"
    assert_includes @response.body, "What Survives After the AI Demo Ends"
    assert_includes @response.body, "Draft"
    assert_includes @response.body, '<html lang="en">'
    assert_includes @response.body, '<meta name="description" content="Essays, notes, and practical writing on AI, software, systems, and the operational edges where products either hold up or fail.">'
    assert_includes @response.body, '<link rel="canonical" href="http://example.com/blog">'
    assert_includes @response.body, '<meta property="og:type" content="website">'
    assert_includes @response.body, '<meta property="og:url" content="http://example.com/blog">'
    assert_includes response.headers["Cache-Control"], "max-age=86400"
    assert_includes response.headers["Cache-Control"], "public"
    assert_includes @response.body, "navigation/AuthControls"
    refute_includes @response.body, "navigation/Navbar"
    assert_includes @response.body, I18n.t("blog_subscriptions.card.title")
    assert_includes @response.body, "blog/BlogSubscribeForm"
  end

  test "blog show is publicly accessible and includes server rendered article html" do
    assert_difference('Ahoy::Event.where(name: "Viewed blog post").count', 1) do
      get blog_post_path("the-first-five-seconds-of-product-trust")
    end

    assert_response :success
    assert_includes @response.body, "<article class=\"blog-prose\">"
    assert_includes @response.body, "Trust starts before understanding"
    assert_includes @response.body, "Most products do not earn trust by explaining everything."
    assert_includes @response.body, '<html lang="en">'
    assert_includes @response.body, '<meta name="description" content="People decide quickly whether a product feels legible. The job is to make that first judgment accurate.">'
    assert_includes @response.body, '<link rel="canonical" href="http://example.com/blog/the-first-five-seconds-of-product-trust">'
    assert_includes @response.body, '<meta property="og:type" content="article">'
    assert_includes @response.body, '<meta property="article:author" content="Andrew Denta">'
    assert_includes @response.body, '<meta property="article:published_time" content="2026-04-01T00:00:00Z">'
    assert_includes @response.body, '"@type":"BlogPosting"'
    assert_includes @response.body, '"url":"http://example.com/blog/the-first-five-seconds-of-product-trust"'
    assert_includes response.headers["Cache-Control"], "max-age=86400"
    assert_includes response.headers["Cache-Control"], "public"
    assert_includes @response.body, "navigation/AuthControls"
    refute_includes @response.body, "navigation/Navbar"
    refute_includes @response.body, "Related posts"
    assert_includes @response.body, I18n.t("blog_subscriptions.card.title")
    assert_includes @response.body, "blog/BlogSubscribeForm"

    event = Ahoy::Event.where(name: "Viewed blog post").order(:time).last
    assert_equal "the-first-five-seconds-of-product-trust", event.properties["slug"]
    assert_equal "The First Five Seconds Of Product Trust", event.properties["title"]
  end

  test "draft post renders on the normal blog route in test" do
    get blog_post_path("notes-on-shipping-before-the-story-hardens")

    assert_response :success
    assert_includes @response.body, "Draft preview"
    assert_includes @response.body, "This is a local-only draft"
  end

  test "walkthrough post renders the youtube embed shortcode" do
    get blog_post_path("interface-walkthrough-video")

    assert_response :success
    assert_includes @response.body, "blog/YouTubeEmbed"
    assert_includes @response.body, "zBPc6Ims1Bc"
  end

  test "unknown published post returns not found" do
    get blog_post_path("missing-post")

    assert_response :not_found
  end

  test "draft posts are hidden on the normal route when preview is disabled" do
    original_env_method = Rails.method(:env)
    Rails.define_singleton_method(:env) { ActiveSupport::StringInquirer.new("production") }

    get blog_post_path("notes-on-shipping-before-the-story-hardens")

    assert_response :not_found
  ensure
    Rails.define_singleton_method(:env, original_env_method)
  end

end
