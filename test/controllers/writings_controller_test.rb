require "test_helper"

class WritingsControllerTest < ActionDispatch::IntegrationTest
  test "writing index is publicly accessible and renders a unified post list" do
    get writing_path

    assert_response :success
    assert_includes @response.body, "writings/index"
    assert_includes @response.body, "<title>Writing | Andrew Denta</title>"
    assert_includes @response.body, "&quot;posts&quot;:["
    assert_includes @response.body, "Context Engineering Is Only Half the Battle"
    assert_includes @response.body, "Why scaffolds matter just as much as context engineering when you want reliable self building software."
    assert_includes @response.body, content_post_path("context-engineering-is-only-half")
    assert_includes @response.body, "creator-commerce-platform-for-a-seed-stage-startup"
    assert_includes @response.body, "&quot;project?&quot;:true"
    refute_includes @response.body, "Add markdown files to publish the first post."
    refute_includes @response.body, "No project entries yet."
    assert_includes @response.body, '<html lang="en">'
    assert_includes @response.body, '<meta name="description" content="Writing.">'
    assert_includes @response.body, '<link rel="canonical" href="http://example.com/writing">'
    assert_includes @response.body, '<meta property="og:type" content="website">'
    assert_includes @response.body, '<meta property="og:url" content="http://example.com/writing">'
    assert_includes response.headers["Cache-Control"], "max-age=86400"
    assert_includes response.headers["Cache-Control"], "public"
    assert_includes @response.body, 'aria-label="Primary"'
    assert_includes @response.body, "&quot;title&quot;:&quot;Subscribe for new posts&quot;"
    assert_includes @response.body, "&quot;createPath&quot;:&quot;/api/v1/blog_subscriptions&quot;"
  end

  test "projects path redirects to writing" do
    get projects_path

    assert_redirected_to writing_path
  end
end
