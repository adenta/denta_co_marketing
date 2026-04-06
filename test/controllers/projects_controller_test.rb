require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "projects index renders the React page with project entries" do
    get projects_path

    assert_response :success
    assert_includes @response.body, "projects/index"
    assert_includes @response.body, "<title>Projects | Andrew Denta</title>"
    assert_includes @response.body, "&quot;projects&quot;:["
    assert_includes @response.body, "creator-commerce-platform-for-a-seed-stage-startup"
    assert_includes @response.body, 'aria-label="Primary"'
  end
end
