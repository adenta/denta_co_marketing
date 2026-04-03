require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
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
