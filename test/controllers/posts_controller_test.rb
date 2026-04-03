require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "writing post renders on the canonical content route and tracks the existing event" do
    assert_difference('Ahoy::Event.where(name: "Viewed blog post").count', 1) do
      get content_post_path("the-first-five-seconds-of-product-trust")
    end

    assert_response :success
    assert_includes @response.body, "<article class=\"blog-prose\">"
    assert_includes @response.body, "Trust starts before understanding"
    assert_includes @response.body, "Most products do not earn trust by explaining everything."
    assert_includes @response.body, '<html lang="en">'
    assert_includes @response.body, '<meta name="description" content="People decide quickly whether a product feels legible. The job is to make that first judgment accurate.">'
    assert_includes @response.body, '<link rel="canonical" href="http://example.com/p/the-first-five-seconds-of-product-trust">'
    assert_includes @response.body, '<meta property="og:type" content="article">'
    assert_includes @response.body, '<meta property="article:author" content="Andrew Denta">'
    assert_includes @response.body, '<meta property="article:published_time" content="2026-04-01T00:00:00Z">'
    assert_includes @response.body, '"@type":"BlogPosting"'
    assert_includes @response.body, '"url":"http://example.com/p/the-first-five-seconds-of-product-trust"'
    assert_includes response.headers["Cache-Control"], "max-age=86400"
    assert_includes response.headers["Cache-Control"], "public"
    assert_includes @response.body, "navigation/SiteNav"
    assert_includes @response.body, "Back to writing"
    assert_includes @response.body, "blog/BlogSubscribeForm"

    event = Ahoy::Event.where(name: "Viewed blog post").order(:time).last
    assert_equal "the-first-five-seconds-of-product-trust", event.properties["slug"]
    assert_equal "The First Five Seconds Of Product Trust", event.properties["title"]
  end

  test "project post renders on the canonical content route without the subscribe card" do
    assert_no_difference('Ahoy::Event.where(name: "Viewed blog post").count') do
      get content_post_path("mangrove-technology-engagements")
    end

    assert_response :success
    assert_includes @response.body, "<title>Mangrove Technology Engagements | Andrew Denta</title>"
    assert_includes @response.body, '<link rel="canonical" href="http://example.com/p/mangrove-technology-engagements">'
    assert_includes @response.body, "Back to projects"
    assert_includes @response.body, "Building systems that teams can keep using"
    refute_includes @response.body, "blog/BlogSubscribeForm"
  end

  test "draft writing post renders on the canonical route in test" do
    get content_post_path("notes-on-shipping-before-the-story-hardens")

    assert_response :success
    assert_includes @response.body, "Draft preview"
    assert_includes @response.body, "This is a local-only draft"
  end

  test "youtube shortcode still renders on the canonical route" do
    get content_post_path("interface-walkthrough-video")

    assert_response :success
    assert_includes @response.body, "blog/YouTubeEmbed"
    assert_includes @response.body, "zBPc6Ims1Bc"
  end

  test "unknown content post returns not found" do
    get content_post_path("missing-post")

    assert_response :not_found
  end

  test "draft posts are hidden on the canonical route when preview is disabled" do
    original_env_method = Rails.method(:env)
    Rails.define_singleton_method(:env) { ActiveSupport::StringInquirer.new("production") }

    get content_post_path("notes-on-shipping-before-the-story-hardens")

    assert_response :not_found
  ensure
    Rails.define_singleton_method(:env, original_env_method)
  end
end
