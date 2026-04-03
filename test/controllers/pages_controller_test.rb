require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "about page renders through the implicit React page fallback" do
    get about_path

    assert_response :success
    assert_includes @response.body, "pages/about"
    assert_includes @response.body, "<title>About | Andrew Denta</title>"
    assert_includes @response.body, "I like software that makes messy work feel legible."
    assert_includes @response.body, "navigation/SiteNav"
  end

  test "services page renders through the implicit React page fallback" do
    get services_path

    assert_response :success
    assert_includes @response.body, "pages/services"
    assert_includes @response.body, "<title>Services | Andrew Denta</title>"
    assert_includes @response.body, "Build AI systems that stay useful after the demo."
    assert_includes @response.body, "Embedded build sprint"
    assert_includes @response.body, "navigation/SiteNav"
  end
end
