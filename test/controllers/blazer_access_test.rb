require "test_helper"

class BlazerAccessTest < ActionDispatch::IntegrationTest
  test "blazer redirects unauthenticated users to sign in" do
    get "/blazer"

    assert_redirected_to "/session/new"
  end

  test "blazer renders for authenticated users" do
    sign_in_as(users(:one))

    get "/blazer"

    assert_response :success
    assert_includes @response.body, "New Query"
  end

  test "blazer dashboard slug routes resolve correctly" do
    sign_in_as(users(:one))
    dashboard = Blazer::Dashboard.create!(name: "Ahoy Overview", creator: users(:one))

    get "/blazer/dashboards/#{dashboard.to_param}"

    assert_response :success
    assert_includes @response.body, "Ahoy Overview"
  end

  test "blazer query slug routes resolve correctly" do
    sign_in_as(users(:one))
    query = Blazer::Query.create!(
      name: "Ahoy top pages",
      statement: "SELECT 1 AS value",
      data_source: "main",
      status: "active",
      creator: users(:one),
    )

    get "/blazer/queries/#{query.to_param}"

    assert_response :success
    assert_includes @response.body, "Ahoy top pages"
  end
end
