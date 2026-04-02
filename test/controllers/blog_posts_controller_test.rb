require "test_helper"

class BlogPostsControllerTest < ActionDispatch::IntegrationTest
  test "blog index is publicly accessible and server renders published post content" do
    get blog_posts_path

    assert_response :success
    assert_includes @response.body, "<title>Writing | Andrew Denta</title>"
    assert_includes @response.body, "Writing on AI, software, and the systems that make ambitious work feel calmer."
    assert_includes @response.body, "Why Dental Practices Lose High-Intent Leads"
    assert_includes @response.body, "Your Website Is Your Best Front Desk"
    assert_includes @response.body, "What Survives After the AI Demo Ends"
    assert_includes @response.body, "Draft"
    assert_includes @response.body, '<html lang="en">'
    assert_includes @response.body, '<meta name="description" content="Essays, notes, and practical writing on AI, software, systems, and the operational edges where products either hold up or fail.">'
    assert_includes @response.body, "navigation/AuthControls"
    refute_includes @response.body, "navigation/Navbar"
  end

  test "blog show is publicly accessible and includes server rendered article html" do
    get blog_post_path("why-dental-practices-lose-leads")

    assert_response :success
    assert_includes @response.body, "<article class=\"blog-prose\">"
    assert_includes @response.body, "Attention does not equal intent"
    assert_includes @response.body, "Most practice websites are built as brochures"
    assert_includes @response.body, "blog/PostEnhancements"
    assert_includes @response.body, '<html lang="en">'
    assert_includes @response.body, '<meta name="description" content="Small conversion leaks compound fast when patients are comparing practices and trying to book quickly.">'
    assert_includes @response.body, "navigation/AuthControls"
    refute_includes @response.body, "navigation/Navbar"
  end

  test "draft post renders on the normal blog route in test" do
    get blog_post_path("your-website-is-your-best-front-desk")

    assert_response :success
    assert_includes @response.body, "Draft preview"
    assert_includes @response.body, "This is a local-only draft"
  end

  test "walkthrough post renders the youtube embed shortcode" do
    get blog_post_path("website-walkthrough-video")

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

    get blog_post_path("your-website-is-your-best-front-desk")

    assert_response :not_found
  ensure
    Rails.define_singleton_method(:env, original_env_method)
  end

end
