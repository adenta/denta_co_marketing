require "commonmarker"

module Content
  class MarkdownRenderer
    RenderedContent = Struct.new(:html, :headings, keyword_init: true)

    ALLOWED_TAGS = %w[
      a blockquote br code del em h1 h2 h3 h4 h5 h6 hr img input li ol p pre span
      strong table tbody td th thead tr ul
    ].freeze
    ALLOWED_ATTRIBUTES = %w[alt checked class disabled href id lang src title type].freeze
    HEADING_SELECTOR = "h1[id], h2[id], h3[id], h4[id], h5[id], h6[id]".freeze
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

    def render(markdown)
      raw_html = Commonmarker.to_html(markdown.to_s.encode("UTF-8"), options: OPTIONS, plugins: PLUGINS)
      fragment = Nokogiri::HTML::DocumentFragment.parse(raw_html)
      fragment.css("script, style").remove

      sanitized_html = sanitize(fragment.to_html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
      sanitized_fragment = Nokogiri::HTML::DocumentFragment.parse(sanitized_html)
      normalize_heading_ids!(sanitized_fragment)

      RenderedContent.new(
        html: sanitized_fragment.to_html,
        headings: extract_headings(sanitized_fragment)
      )
    end

    private

    include ActionView::Helpers::SanitizeHelper

    def normalize_heading_ids!(fragment)
      fragment.css("h1 > a.anchor[id]:first-child, h2 > a.anchor[id]:first-child, h3 > a.anchor[id]:first-child, h4 > a.anchor[id]:first-child, h5 > a.anchor[id]:first-child, h6 > a.anchor[id]:first-child").each do |anchor|
        heading = anchor.parent
        heading["id"] ||= anchor["id"]
        anchor.remove
      end
    end

    def extract_headings(fragment)
      fragment.css(HEADING_SELECTOR).map do |heading|
        {
          "id" => heading["id"],
          "level" => heading.name.delete_prefix("h").to_i,
          "text" => heading.text.squish
        }
      end
    end
  end
end
