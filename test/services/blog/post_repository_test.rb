require "test_helper"
require "tmpdir"

module Blog
  class PostRepositoryTest < ActiveSupport::TestCase
    test "loads published posts and hides drafts by default" do
      with_repository do |repository, root:, **|
        write_post(
          root.join("older.md"),
          title: "Older",
          excerpt: "Older excerpt",
          published_on: "2026-03-30"
        )
        write_post(
          root.join("newer.md"),
          title: "Newer",
          excerpt: "Newer excerpt",
          published_on: "2026-04-01"
        )
        write_post(
          root.join("draft.md"),
          title: "Draft",
          excerpt: "Draft excerpt",
          published_on: "2026-04-02",
          draft: true
        )

        assert_equal %w[newer older], repository.published_posts.map(&:slug)
      end
    end

    test "includes drafts when requested" do
      with_repository do |repository, root:, **|
        write_post(
          root.join("published.md"),
          title: "Published",
          excerpt: "Published excerpt",
          published_on: "2026-04-01"
        )
        write_post(
          root.join("draft.md"),
          title: "Draft",
          excerpt: "Draft excerpt",
          published_on: "2026-04-02",
          draft: true
        )

        posts = repository.published_posts(include_drafts: true)

        assert_equal %w[draft published], posts.map(&:slug)
        assert_predicate posts.first, :draft?
      end
    end

    test "finds a published post by slug" do
      with_repository do |repository, root:, **|
        write_post(
          root.join("slug-test.md"),
          title: "Slug Test",
          excerpt: "Excerpt",
          published_on: "2026-04-01"
        )

        post = repository.published_post_by_slug!("slug-test")

        assert_equal "Slug Test", post.title
        assert_equal Date.new(2026, 4, 1), post.published_on
      end
    end

    test "hides draft posts by slug unless drafts are included" do
      with_repository do |repository, root:, **|
        write_post(
          root.join("draft-only.md"),
          title: "Draft Only",
          excerpt: "Excerpt",
          published_on: "2026-04-01",
          draft: true
        )

        assert_raises(ActiveRecord::RecordNotFound) { repository.published_post_by_slug!("draft-only") }
        assert_predicate repository.published_post_by_slug!("draft-only", include_drafts: true), :draft?
      end
    end

    test "raises for malformed frontmatter" do
      with_repository do |repository, root:, **|
        File.write(
          root.join("broken.md"),
          <<~MARKDOWN
            ---
            title: Broken
            published_on: 2026-04-01
            ---

            Missing excerpt
          MARKDOWN
        )

        assert_raises(Blog::PostRepository::InvalidPostError) { repository.published_posts }
      end
    end

    test "reuses cached rendered posts until the file mtime changes" do
      with_repository(renderer: CountingRenderer.new) do |repository, published_root:, renderer:, **|
        path = published_root.join("cached.md")
        write_post(
          path,
          title: "Cached",
          excerpt: "Excerpt",
          published_on: "2026-04-01",
          body: "# Cached\n\nFirst body."
        )

        repository.published_post_by_slug!("cached")
        repository.published_post_by_slug!("cached")

        assert_equal 1, renderer.calls

        sleep 1.1
        write_post(
          path,
          title: "Cached",
          excerpt: "Excerpt",
          published_on: "2026-04-01",
          body: "# Cached\n\nUpdated body."
        )

        repository.published_post_by_slug!("cached")

        assert_equal 2, renderer.calls
      end
    end

    private

    CountingRenderer = Struct.new(:calls, keyword_init: true) do
      def render(markdown)
        self.calls ||= 0
        self.calls += 1
        Blog::MarkdownRenderer::RenderedContent.new(
          html: "<p>#{ERB::Util.html_escape(markdown)}</p>",
          headings: []
        )
      end
    end

    def with_repository(renderer: Blog::MarkdownRenderer.new)
      Dir.mktmpdir("blog-post-repository-test") do |root|
        published_root = Pathname(root).join("content/blog")
        FileUtils.mkdir_p(published_root)

        cache = ActiveSupport::Cache::MemoryStore.new
        repository = Blog::PostRepository.new(
          root: published_root,
          renderer:,
          cache:
        )

        yield repository, root: published_root, published_root:, renderer:, cache:
      end
    end

    def write_post(path, title:, excerpt:, published_on:, body: "# Heading\n\nBody", author: "Denta Co", draft: false)
      File.write(
        path,
        <<~MARKDOWN
          ---
          title: #{title}
          excerpt: #{excerpt}
          published_on: #{published_on}
          author: #{author}
          draft: #{draft}
          ---

          #{body}
        MARKDOWN
      )
    end
  end
end
