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

      assert_includes result.html, %(<h1 id="title">)
      assert_includes result.html, %(<a href="https://example.com">a link</a>)
      assert_includes result.html, "<blockquote>"
      assert_includes result.html, "<pre lang=\"rb\"><code>"
      assert_includes result.html, "<table>"
      assert_equal [ { "id" => "title", "level" => 1, "text" => "Title" } ], result.headings
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

    test "turns standalone youtube links into turbo mount embeds" do
      result = MarkdownRenderer.new.render(<<~MARKDOWN)
        Before

        https://youtu.be/zBPc6Ims1Bc?si=W2pKuAq7oS6i1uHc&t=1675

        After
      MARKDOWN

      assert_includes result.html, %(data-controller="turbo-mount-blog--you-tube-embed")
      assert_includes result.html, %(data-turbo-mount-blog--you-tube-embed-component-value="blog/YouTubeEmbed")
      assert_includes result.html, "zBPc6Ims1Bc"
      assert_includes result.html, "\\u0026t=1675"
      assert_includes result.html, "<p>Before</p>"
      assert_includes result.html, "<p>After</p>"
    end
  end
end
