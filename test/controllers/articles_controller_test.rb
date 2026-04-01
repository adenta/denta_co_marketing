require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "show renders article page for a valid slug" do
    get article_path("what-survives-after-the-ai-demo-ends")

    assert_response :success
    assert_includes @response.body, "What Survives After the AI Demo Ends"
    assert_includes @response.body, "There is a predictable moment in a lot of AI projects"
    refute_includes @response.body, "data-turbo-mount-articles--show-component-value"
  end

  test "show raises not found for an unknown slug" do
    get article_path("missing-article")

    assert_response :not_found
  end
end
