require "test_helper"

module Blog
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
      assert_includes result.html, "<pre class=\"ruby\">"
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
  end
end
