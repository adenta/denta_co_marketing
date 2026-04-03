require "commonmarker"
require "uri"

module Content
  class MarkdownRenderer
    ShortcodeError = Class.new(StandardError)
    RenderedContent = Struct.new(:html, keyword_init: true)

    ALLOWED_TAGS = %w[
      a blockquote br code del em h1 h2 h3 h4 h5 h6 hr img input li ol p pre span
      strong table tbody td th thead tr ul
    ].freeze
    ALLOWED_ATTRIBUTES = %w[alt checked class disabled href id lang src title type].freeze
    OPTIONS = {
      parse: {
        smart: true
      },
      render: {
        unsafe: false
      },
      extension: {
        autolink: true,
        footnotes: true,
        strikethrough: true,
        table: true,
        tagfilter: true,
        tasklist: true,
        header_ids: ""
      }
    }.freeze
    PLUGINS = {
      syntax_highlighter: nil
    }.freeze
    YOUTUBE_COMPONENT_NAME = "blog/YouTubeEmbed".freeze
    YOUTUBE_HOSTS = %w[
      youtube.com
      www.youtube.com
      m.youtube.com
      youtu.be
      www.youtu.be
    ].freeze

    def render(markdown)
      raw_html = Commonmarker.to_html(markdown.to_s.encode("UTF-8"), options: OPTIONS, plugins: PLUGINS)
      fragment = Nokogiri::HTML::DocumentFragment.parse(raw_html)
      fragment.css("script, style").remove

      sanitized_html = sanitize(fragment.to_html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
      sanitized_fragment = Nokogiri::HTML::DocumentFragment.parse(sanitized_html)
      replace_youtube_embeds!(sanitized_fragment)
      decorate_headings!(sanitized_fragment)

      RenderedContent.new(
        html: sanitized_fragment.to_html
      )
    end

    private

    include ActionView::Helpers::SanitizeHelper
    include ERB::Util

    YOUTUBE_SHORTCODE_NAME = "youtube".freeze
    SHORTCODE_REGEX = /\A\{\{\s*(?<name>[a-z0-9_-]+)(?:\s+url=(?<quote>["“])(?<url>.+?)(?<closing_quote>["”]))?\s*\}\}\z/.freeze

    def replace_youtube_embeds!(fragment)
      fragment.css("p").each do |paragraph|
        shortcode = shortcode_for(paragraph)
        next unless shortcode

        paragraph.replace(turbo_mount_html(YOUTUBE_COMPONENT_NAME, props: { url: shortcode.fetch(:url) }))
      end
    end

    def shortcode_for(paragraph)
      text = paragraph.text.to_s.strip
      return if text.blank?
      return unless text.start_with?("{{") || text.end_with?("}}")

      match = SHORTCODE_REGEX.match(text)
      raise ShortcodeError, %(Invalid content shortcode: #{text}) unless match

      name = match[:name]
      raise ShortcodeError, %(Unsupported content shortcode "#{name}") unless name == YOUTUBE_SHORTCODE_NAME
      raise ShortcodeError, %(YouTube shortcode must include a url: #{text}) if match[:url].blank?

      url = match[:url]
      raise ShortcodeError, %(YouTube shortcode requires a valid YouTube URL: #{url}) unless youtube_url?(url)

      { url: }
    end

    def youtube_url?(value)
      uri = URI.parse(value.to_s)
      return false unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

      YOUTUBE_HOSTS.include?(uri.host.to_s.downcase)
    rescue URI::InvalidURIError
      false
    end

    def turbo_mount_html(component_name, props:)
      controller_name = "turbo-mount-#{component_name.underscore.dasherize.gsub("/", "--")}"
      props_attribute = %(data-#{controller_name}-props-value="#{html_escape(props.to_json)}")

      <<~HTML.chomp
        <div data-controller="#{html_escape(controller_name)}" data-#{controller_name}-component-value="#{html_escape(component_name)}" #{props_attribute}></div>
      HTML
    end

    HEADING_ANCHOR_SELECTOR = "h1 > a.anchor[id]:first-child, h2 > a.anchor[id]:first-child, h3 > a.anchor[id]:first-child, h4 > a.anchor[id]:first-child, h5 > a.anchor[id]:first-child, h6 > a.anchor[id]:first-child".freeze
    HEADING_LINK_LABEL = "Copy link to this section".freeze

    def decorate_headings!(fragment)
      fragment.css(HEADING_ANCHOR_SELECTOR).each do |anchor|
        heading = anchor.parent
        heading_id = anchor["id"].presence
        next unless heading && heading_id

        heading["id"] ||= heading_id
        anchor.remove
        heading.add_child(build_heading_link(fragment.document, heading_id))
      end
    end

    def build_heading_link(document, heading_id)
      link = Nokogiri::XML::Node.new("a", document)
      link["class"] = "heading-anchor"
      link["href"] = "##{heading_id}"
      link["title"] = HEADING_LINK_LABEL
      link["aria-label"] = HEADING_LINK_LABEL
      link
    end
  end
end
