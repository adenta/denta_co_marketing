require "test_helper"

module Content
  class FrontMatterParserTest < ActiveSupport::TestCase
    test "parses front matter and body" do
      parsed = FrontMatterParser.new.parse(<<~MARKDOWN, path: "example.md")
        ---
        title: Example
        published_on: 2026-04-01
        ---

        # Heading
      MARKDOWN

      assert_equal({ "title" => "Example", "published_on" => Date.new(2026, 4, 1) }, parsed.metadata)
      assert_equal "\n# Heading\n", parsed.body
    end

    test "requires front matter at the beginning of the document" do
      error = assert_raises(FrontMatterParser::ParseError) do
        FrontMatterParser.new.parse("Intro\n---\ntitle: Example\n---\n", path: "example.md")
      end

      assert_includes error.message, "Missing front matter"
    end

    test "rejects malformed yaml" do
      error = assert_raises(FrontMatterParser::ParseError) do
        FrontMatterParser.new.parse(<<~MARKDOWN, path: "example.md")
          ---
          title: [broken
          ---

          Body
        MARKDOWN
      end

      assert_includes error.message, "Invalid front matter"
    end

    test "rejects duplicate keys" do
      error = assert_raises(FrontMatterParser::ParseError) do
        FrontMatterParser.new.parse(<<~MARKDOWN, path: "example.md")
          ---
          title: First
          title: Second
          ---

          Body
        MARKDOWN
      end

      assert_includes error.message, "Duplicate front matter keys"
    end

    test "rejects yaml aliases" do
      error = assert_raises(FrontMatterParser::ParseError) do
        FrontMatterParser.new.parse(<<~MARKDOWN, path: "example.md")
          ---
          defaults: &defaults
            title: Example
          article: *defaults
          ---

          Body
        MARKDOWN
      end

      assert_includes error.message, "Invalid front matter"
    end
  end
end
