require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "about page renders through the implicit React page fallback" do
    get about_path

    assert_response :success
    assert_includes @response.body, "pages/about"
    assert_includes @response.body, "<title>About | Andrew Denta</title>"
    assert_includes @response.body, '<meta name="description" content="About page scaffold ready for a new narrative.">'
    refute_includes @response.body, "data-turbo-mount-pages--about-props-value"
    assert_includes @response.body, "navigation/SiteNav"
  end

  test "services page renders through the implicit React page fallback" do
    get services_path

    assert_response :success
    assert_includes @response.body, "pages/services"
    assert_includes @response.body, "<title>Services | Andrew Denta</title>"
    assert_includes @response.body, '<meta name="description" content="Services page scaffold ready for a new offer structure.">'
    refute_includes @response.body, "data-turbo-mount-pages--services-props-value"
    assert_includes @response.body, "navigation/SiteNav"
  end
end
