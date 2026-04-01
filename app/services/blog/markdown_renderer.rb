require "rdoc"
require "rdoc/markdown"
require "rdoc/markup/to_html"

module Blog
  class MarkdownRenderer
    RenderedContent = Struct.new(:html, :headings, keyword_init: true)

    ALLOWED_TAGS = %w[
      a blockquote br code del em h1 h2 h3 h4 h5 h6 hr img li ol p pre span
      strong table tbody td th thead tr ul
    ].freeze
    ALLOWED_ATTRIBUTES = %w[alt class href id src title].freeze
    HEADING_SELECTOR = "h1[id], h2[id], h3[id], h4[id], h5[id], h6[id]".freeze

    def render(markdown)
      document = parser.parse(markdown.to_s)
      raw_html = RDoc::Markup::ToHtml.new(RDoc::Options.new).convert(document)

      fragment = Nokogiri::HTML::DocumentFragment.parse(raw_html)
      fragment.css("script, style").remove

      sanitized_html = sanitize(fragment.to_html, tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
      sanitized_fragment = Nokogiri::HTML::DocumentFragment.parse(sanitized_html)
      sanitized_fragment.css("span.legacy-anchor").remove

      RenderedContent.new(
        html: sanitized_fragment.to_html,
        headings: extract_headings(sanitized_fragment)
      )
    end

    private

    include ActionView::Helpers::SanitizeHelper

    def parser
      @parser ||= RDoc::Markdown.new
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
