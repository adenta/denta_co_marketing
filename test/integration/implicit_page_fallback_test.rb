require "test_helper"
require "fileutils"

class TestFallbackPagesController < ApplicationController
  allow_unauthenticated_access

  def with_template
    @props = { source: "template" }
  end

  def with_page
    @props = { foo: "bar" }
  end

  def no_props; end

  def missing_page; end
end

class ImplicitPageFallbackTest < ActionDispatch::IntegrationTest
  parallelize(workers: 1)

  setup do
    FileUtils.mkdir_p(Rails.root.join("app/views/test_fallback_pages"))
    FileUtils.mkdir_p(Rails.root.join("app/javascript/pages/test_fallback_pages"))

    File.write(
      Rails.root.join("app/views/test_fallback_pages/with_template.html.erb"),
      "<p>template-wins</p>\n",
    )

    File.write(
      Rails.root.join("app/javascript/pages/test_fallback_pages/with_page.tsx"),
      "export default function WithPage() { return null; }\n",
    )

    File.write(
      Rails.root.join("app/javascript/pages/test_fallback_pages/no_props.tsx"),
      "export default function NoProps() { return null; }\n",
    )
  end

  teardown do
    FileUtils.rm_rf(Rails.root.join("app/views/test_fallback_pages"))
    FileUtils.rm_rf(Rails.root.join("app/javascript/pages/test_fallback_pages"))
  end

  test "renders existing erb template when present" do
    with_test_routes do
      get "/with_template"

      assert_response :success
      assert_includes @response.body, "template-wins"
      refute_includes @response.body, "test_fallback_pages/with_template"
    end
  end

  test "falls back to pages component and serializes props" do
    with_test_routes do
      get "/with_page"

      assert_response :success
      assert_includes(
        @response.body,
        'data-turbo-mount-test-fallback-pages--with-page-component-value="test_fallback_pages/with_page"',
      )
      assert_includes(
        @response.body,
        'data-turbo-mount-test-fallback-pages--with-page-props-value="{&quot;foo&quot;:&quot;bar&quot;}"',
      )
    end
  end

  test "raises when both erb template and page component are missing" do
    with_test_routes do
      get "/missing_page"

      assert_response :not_acceptable
      assert_includes @response.body, "No view template for interactive request"
    end
  end

  test "omits props attribute when @props is unset" do
    with_test_routes do
      get "/no_props"

      assert_response :success
      assert_includes(
        @response.body,
        'data-turbo-mount-test-fallback-pages--no-props-component-value="test_fallback_pages/no_props"',
      )
      refute_match(/data-turbo-mount-test-fallback-pages--no-props-props-value/, @response.body)
    end
  end

  private

  def with_test_routes
    with_routing do |set|
      set.draw do
        get "/with_template" => "test_fallback_pages#with_template"
        get "/with_page" => "test_fallback_pages#with_page"
        get "/no_props" => "test_fallback_pages#no_props"
        get "/missing_page" => "test_fallback_pages#missing_page"
      end

      yield
    end
  end
end
