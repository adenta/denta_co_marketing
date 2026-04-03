class PostsController < ApplicationController
  allow_unauthenticated_access

  def show
    @post = repository.post_by_slug!(params[:slug], include_drafts: preview_enabled?)

    return unless cache_public_page!(
      etag: [ "content-show", @post.slug, @post.source_updated_at&.to_i, I18n.locale ],
      last_modified: [ translations_last_updated_at, @post.source_updated_at, @post.published_on.in_time_zone ].compact.max,
    )

    @page_meta = page_meta_for(@post)

    unless @post.project?
      ahoy.track "Viewed blog post", slug: @post.slug, title: @post.title
    end
  end

  private

  def current_nav_key
    @post&.project? ? "projects" : "blog"
  end

  def repository
    @repository ||= Blog::PostRepository.new
  end

  def preview_enabled?
    Rails.env.development? || Rails.env.test?
  end

  def page_meta_for(post)
    return project_page_meta(post) if post.project?

    BlogPostPageMetaBlueprint.render_as_hash(
      post,
      application_name: I18n.t("site.meta.application_name", default: "Andrew Denta"),
      base_url: helpers.absolute_page_url("/"),
      image_url: helpers.absolute_page_url(BlogPostPageMetaBlueprint::DEFAULT_SOCIAL_IMAGE_PATH),
      locale: I18n.locale,
      site_title: I18n.t("site.meta.default_title", default: "Andrew Denta"),
    )
  end

  def project_page_meta(post)
    site_title = I18n.t("site.meta.default_title", default: "Andrew Denta")

    {
      title: "#{post.title} | #{site_title}",
      description: post.excerpt,
      canonical: content_post_path(post.slug)
    }
  end
end
