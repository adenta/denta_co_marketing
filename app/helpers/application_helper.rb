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

  def resolved_page_meta
    @resolved_page_meta ||= begin
      default_title = I18n.t("site.meta.default_title", default: "Andrew Denta")
      raw_page_meta = @page_meta || {}

      {
        title: raw_page_meta[:title].presence || content_for(:title) || default_title,
        description: raw_page_meta[:description].presence || content_for(:meta_description),
        canonical_url: absolute_page_url(raw_page_meta[:canonical]) || current_page_url,
        image_url: absolute_page_url(raw_page_meta[:image]) || default_social_image_url,
        og_type: raw_page_meta[:og_type].presence || "website",
        twitter_card: raw_page_meta[:twitter_card].presence || "summary_large_image",
        author: raw_page_meta[:author].presence,
        published_time: normalized_meta_time(raw_page_meta[:published_time]),
        structured_data: Array(raw_page_meta[:structured_data]).compact
      }
    end
  end

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

  def absolute_page_url(value)
    return if value.blank?

    case value
    when String
      return value if value.start_with?("http://", "https://")

      URI.join(public_base_url, value).to_s
    when Hash
      url_for(default_public_url_options.merge(value).merge(only_path: false))
    end
  end

  def current_page_url
    URI.join(public_base_url, request.path).to_s
  end

  def default_social_image_url
    absolute_page_url("/andrew-denta-2026.jpeg")
  end

  def normalized_meta_time(value)
    case value
    when Date
      value.in_time_zone
    when Time, DateTime, ActiveSupport::TimeWithZone
      value
    end
  end

  def default_public_url_options
    Rails.application.routes.default_url_options.symbolize_keys.slice(:protocol, :host, :port)
  end

  def public_base_url
    @public_base_url ||= begin
      options = default_public_url_options
      return request.base_url if options[:host].blank?

      port = normalized_public_port(options[:protocol], options[:port])

      URI::Generic.build(
        scheme: options.fetch(:protocol, "https"),
        host: options.fetch(:host),
        port: port,
      ).to_s
    end
  end

  def normalized_public_port(protocol, port)
    return if port.blank?

    numeric_port = port.to_i
    default_port = URI::Generic.default_port(protocol.to_s)
    return if numeric_port == default_port

    numeric_port
  end

  private
end
