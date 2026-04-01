require "test_helper"
require "tmpdir"

class ArticleRepositoryTest < ActiveSupport::TestCase
  test "renders article markdown into sanitized html" do
    with_article_root do |root|
      write_article(
        root.join("example.md"),
        title: "Example",
        category: "Operations",
        published_on: "2026-04-01",
        summary: "Summary",
        body: <<~MARKDOWN
          ## Heading

          Paragraph with [a link](https://example.com) and ~~edited~~ text.

          * one
          * two
        MARKDOWN
      )

      with_stubbed_article_root(root) do
        article = ArticleRepository.find_by_slug("example")

        assert_match %r{<h2 id="heading">\s*Heading</h2>}m, article.html_body
        assert_includes article.html_body, %(<a href="https://example.com">a link</a>)
        assert_includes article.html_body, "<del>edited</del>"
        assert_equal [ { "id" => "heading", "level" => 2, "text" => "Heading" } ], article.headings
      end
    end
  end

  test "rejects unknown article front matter keys" do
    with_article_root do |root|
      write_article(
        root.join("example.md"),
        title: "Example",
        category: "Operations",
        published_on: "2026-04-01",
        summary: "Summary",
        extra_front_matter: "unknown: nope\n"
      )

      with_stubbed_article_root(root) do
        error = assert_raises(Content::MetadataSchema::ValidationError) do
          ArticleRepository.all
        end

        assert_includes error.message, "Unknown front matter keys"
      end
    end
  end

  private

  def with_article_root
    Dir.mktmpdir("article-repository-test") do |root|
      content_root = Pathname(root)
      yield content_root
    end
  end

  def with_stubbed_article_root(root)
    original_root = ArticleRepository.send(:remove_const, :CONTENT_ROOT)
    ArticleRepository.const_set(:CONTENT_ROOT, root)
    Rails.cache.clear
    yield
  ensure
    ArticleRepository.send(:remove_const, :CONTENT_ROOT)
    ArticleRepository.const_set(:CONTENT_ROOT, original_root)
    Rails.cache.clear
  end

  def write_article(path, title:, category:, published_on:, summary:, body: "Body", extra_front_matter: "")
    File.write(
      path,
      <<~MARKDOWN
        ---
        title: #{title}
        category: #{category}
        published_on: #{published_on}
        summary: #{summary}
        #{extra_front_matter}---

        #{body}
      MARKDOWN
    )
  end
end
