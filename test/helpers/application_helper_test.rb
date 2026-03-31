# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "favicon_paths prefers local icons in development when generated assets exist" do
    rails_singleton = Rails.singleton_class
    helper_singleton = singleton_class
    original_env = Rails.env
    existing_file = Struct.new(:exist?).new(true)

    rails_singleton.send(:define_method, :env) { ActiveSupport::StringInquirer.new("development") }
    helper_singleton.send(:define_method, :local_favicon_png_path) { existing_file }
    helper_singleton.send(:define_method, :local_favicon_svg_path) { existing_file }

    assert_equal(
      {
        png: "/codex-local-favicons/favicon.png",
        svg: "/codex-local-favicons/favicon.svg"
      },
      favicon_paths
    )
  ensure
    helper_singleton.send(:remove_method, :local_favicon_png_path) if helper_singleton.method_defined?(:local_favicon_png_path)
    helper_singleton.send(:remove_method, :local_favicon_svg_path) if helper_singleton.method_defined?(:local_favicon_svg_path)
    rails_singleton.send(:define_method, :env) { original_env }
  end

  test "favicon_paths falls back to shared icons outside development" do
    rails_singleton = Rails.singleton_class
    original_env = Rails.env

    rails_singleton.send(:define_method, :env) { ActiveSupport::StringInquirer.new("test") }

    assert_equal(
      {
        png: "/icon.png",
        svg: "/icon.svg"
      },
      favicon_paths
    )
  ensure
    rails_singleton.send(:define_method, :env) { original_env }
  end
end
