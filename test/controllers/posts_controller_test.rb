require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  test "published writing posts render and track a page view" do
    assert_difference('Ahoy::Event.where(name: "Viewed blog post").count', 1) do
      get content_post_path("context-engineering-is-only-half")
    end

    assert_response :success
    assert_includes @response.body, "<title>Context Engineering Is Only Half the Battle | Andrew Denta</title>"
    assert_includes @response.body, "Why scaffolds matter just as much as context engineering when you want reliable self building software."
    assert_includes @response.body, "turbo-mount-blog--you-tube-embed"
    assert_includes @response.body, "8IkufN4_Tr0"
    assert_includes @response.body, "Back to writing"
  end

  test "project posts render with a project badge and do not track a blog page view" do
    assert_no_difference('Ahoy::Event.where(name: "Viewed blog post").count') do
      get content_post_path("creator-commerce-platform-for-a-seed-stage-startup")
    end

    assert_response :success
    assert_includes @response.body, "<title>Creator Commerce Platform for a Seed-Stage Startup | Andrew Denta</title>"
    assert_includes @response.body, "Project"
    assert_includes @response.body, "bg-orange-100"
    assert_includes @response.body, "Back to writing"
    refute_includes @response.body, "Subscribe for new posts"
  end

  test "removed writing posts return not found and do not track an event" do
    assert_no_difference('Ahoy::Event.where(name: "Viewed blog post").count') do
      get content_post_path("the-first-five-seconds-of-product-trust")
    end

    assert_response :not_found
  end

  test "removed project posts return not found" do
    assert_no_difference('Ahoy::Event.where(name: "Viewed blog post").count') do
      get content_post_path("mangrove-technology-engagements")
    end

    assert_response :not_found
  end

  test "removed draft writing posts return not found in test" do
    get content_post_path("notes-on-shipping-before-the-story-hardens")

    assert_response :not_found
  end

  test "removed video posts return not found" do
    get content_post_path("interface-walkthrough-video")

    assert_response :not_found
  end

  test "unknown content post returns not found" do
    get content_post_path("missing-post")

    assert_response :not_found
  end

  test "removed draft posts return not found when preview is disabled" do
    original_env_method = Rails.method(:env)
    Rails.define_singleton_method(:env) { ActiveSupport::StringInquirer.new("production") }

    get content_post_path("notes-on-shipping-before-the-story-hardens")

    assert_response :not_found
  ensure
    Rails.define_singleton_method(:env, original_env_method)
  end
end
