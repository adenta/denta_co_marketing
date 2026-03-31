module ApplicationHelper
  def favicon_paths
    if local_favicon_available?
      {
        png: "/codex-local-favicons/favicon.png",
        svg: "/codex-local-favicons/favicon.svg"
      }
    else
      {
        png: "/icon.png",
        svg: "/icon.svg"
      }
    end
  end

  private

  def local_favicon_available?
    return false unless Rails.env.development?

    local_favicon_png_path.exist? && local_favicon_svg_path.exist?
  end

  def local_favicon_png_path
    Rails.root.join("public/codex-local-favicons/favicon.png")
  end

  def local_favicon_svg_path
    Rails.root.join("public/codex-local-favicons/favicon.svg")
  end
end
