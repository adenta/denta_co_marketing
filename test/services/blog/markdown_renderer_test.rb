require "test_helper"

module Content
  class MarkdownRendererTest < ActiveSupport::TestCase
    test "renders core markdown structures to sanitized html" do
      result = MarkdownRenderer.new.render(<<~MARKDOWN)
        # Title

        Paragraph with [a link](https://example.com).

        > Quoted text

        * one
        * two

        ```rb
        puts 1
        ```

        | a | b |
        | --- | --- |
        | 1 | 2 |
      MARKDOWN

      fragment = Nokogiri::HTML::DocumentFragment.parse(result.html)
      heading = fragment.at_css("h1")
      heading_link = heading.at_css("a.heading-anchor")

      assert_equal "title", heading["id"]
      assert_equal "#title", heading_link["href"]
      assert_equal "Copy link to this section", heading_link["title"]
      assert_equal "Copy link to this section", heading_link["aria-label"]
      refute heading.at_css("a.anchor")
      assert_includes result.html, %(<a href="https://example.com">a link</a>)
      assert_includes result.html, "<blockquote>"
      assert_includes result.html, "<pre lang=\"rb\"><code>"
      assert_includes result.html, "<table>"
    end

    test "removes unsafe script tags entirely" do
      result = MarkdownRenderer.new.render(<<~MARKDOWN)
        # Safe

        <script>alert("xss")</script>
      MARKDOWN

      refute_includes result.html, "<script"
      refute_includes result.html, "alert"
    end

    test "removes unsafe link protocols" do
      result = MarkdownRenderer.new.render("[bad](javascript:alert('xss'))")

      refute_includes result.html, "javascript:"
    end

    test "turns explicit youtube shortcodes into turbo mount embeds" do
      result = MarkdownRenderer.new.render(<<~MARKDOWN)
        Before

        {{ youtube url="https://youtu.be/zBPc6Ims1Bc?si=W2pKuAq7oS6i1uHc&t=1675" }}

        After
      MARKDOWN

      assert_includes result.html, %(data-controller="turbo-mount-blog--you-tube-embed")
      assert_includes result.html, %(data-turbo-mount-blog--you-tube-embed-component-value="blog/YouTubeEmbed")
      assert_includes result.html, "zBPc6Ims1Bc"
      assert_includes result.html, "\\u0026t=1675"
      assert_includes result.html, "<p>Before</p>"
      assert_includes result.html, "<p>After</p>"
    end

    test "leaves standalone youtube links as regular links" do
      result = MarkdownRenderer.new.render(<<~MARKDOWN)
        https://youtu.be/zBPc6Ims1Bc?si=W2pKuAq7oS6i1uHc&t=1675
      MARKDOWN

      refute_includes result.html, %(data-controller="turbo-mount-blog--you-tube-embed")
      assert_includes result.html, %(href="https://youtu.be/zBPc6Ims1Bc?si=W2pKuAq7oS6i1uHc&amp;t=1675")
    end

    test "raises for malformed youtube shortcodes" do
      error = assert_raises(MarkdownRenderer::ShortcodeError) do
        MarkdownRenderer.new.render(<<~MARKDOWN)
          {{ youtube url="https://youtu.be/zBPc6Ims1Bc"
        MARKDOWN
      end

      assert_includes error.message, "Invalid content shortcode"
    end

    test "raises for youtube shortcodes without urls" do
      error = assert_raises(MarkdownRenderer::ShortcodeError) do
        MarkdownRenderer.new.render(<<~MARKDOWN)
          {{ youtube }}
        MARKDOWN
      end

      assert_includes error.message, "must include a url"
    end

    test "raises for non-youtube shortcode urls" do
      error = assert_raises(MarkdownRenderer::ShortcodeError) do
        MarkdownRenderer.new.render(<<~MARKDOWN)
          {{ youtube url="https://example.com/video" }}
        MARKDOWN
      end

      assert_includes error.message, "requires a valid YouTube URL"
    end
  end
end
