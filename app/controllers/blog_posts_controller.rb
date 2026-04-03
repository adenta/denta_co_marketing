class BlogPostsController < ApplicationController
  allow_unauthenticated_access

  def index
    page_content = localized_copy("pages.blog.index")
    @posts = repository.published_posts(include_drafts: preview_enabled?)

    return unless cache_public_page!(
      etag: [ "blog-index", I18n.locale, preview_enabled?, @posts.map { |post| [ post.slug, post.source_updated_at&.to_i ] } ],
      last_modified: [ translations_last_updated_at, repository.latest_updated_at(include_drafts: preview_enabled?) ].compact.max,
    )

    @page_meta = page_content.fetch(:meta)
    @page_content = page_content.except(:meta)
  end

  def show
    @post = repository.published_post_by_slug!(params[:slug], include_drafts: preview_enabled?)

    return unless cache_public_page!(
      etag: [ "blog-show", @post.slug, @post.source_updated_at&.to_i, I18n.locale ],
      last_modified: [ translations_last_updated_at, @post.source_updated_at, @post.published_on.in_time_zone ].compact.max,
    )

    @page_meta = BlogPostPageMetaBlueprint.render_as_hash(
      @post,
      application_name: I18n.t("site.meta.application_name", default: "Andrew Denta"),
      base_url: helpers.absolute_page_url("/"),
      image_url: helpers.absolute_page_url(BlogPostPageMetaBlueprint::DEFAULT_SOCIAL_IMAGE_PATH),
      locale: I18n.locale,
      site_title: I18n.t("site.meta.default_title", default: "Andrew Denta"),
    )
    ahoy.track "Viewed blog post", slug: @post.slug, title: @post.title
  end

  private

  def repository
    @repository ||= Blog::PostRepository.new
  end

  def preview_enabled?
    Rails.env.development? || Rails.env.test?
  end
end
