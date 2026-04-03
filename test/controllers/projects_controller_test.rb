require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  test "projects index renders the React page and includes only project entries" do
    get projects_path

    assert_response :success
    assert_includes @response.body, "projects/index"
    assert_includes @response.body, "<title>Projects | Andrew Denta</title>"
    assert_includes @response.body, "&quot;projects&quot;:["
    assert_includes @response.body, "Mangrove Technology Engagements"
    assert_includes @response.body, "Terusama"
    refute_includes @response.body, "The First Five Seconds Of Product Trust"
    refute_includes @response.body, "sales wrapper"
    assert_includes @response.body, 'aria-label="Primary"'
  end
end
