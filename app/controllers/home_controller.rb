class HomeController < ApplicationController
  def index
    featured_posts = repository.featured_blog_posts(include_drafts: preview_enabled?).first(3)

    return unless cache_public_page!(
      etag: [ "home", I18n.locale, preview_enabled?, featured_posts.map { |post| [ post.slug, post.source_updated_at&.to_i ] } ],
      last_modified: [ translations_last_updated_at, repository.latest_updated_at(include_drafts: preview_enabled?) ].compact.max,
    )

    @page_meta = {
      title: I18n.t("site.meta.default_title", default: "Andrew Denta"),
      description: I18n.t("home.index.subtitle")
    }
    @props = {
      title: I18n.t("home.index.title"),
      subtitle: I18n.t("home.index.subtitle"),
      trustedBy: {
        heading: I18n.t("home.index.trusted_by.heading"),
        subtitle: I18n.t("home.index.trusted_by.subtitle"),
        fixedLogoNames: [ "insight", "reid", "jp-morgan" ],
        rotationIntervalMs: 3400,
        transitionDurationMs: 260,
        staggerDelayMs: 140
      },
      featuredPostsHeading: I18n.t("home.index.featured_posts.heading"),
      featuredPostsPath: writing_path,
      featuredPostsEmpty: I18n.t("home.index.featured_posts.empty"),
      featuredPosts: PostBlueprint.render_as_hash(featured_posts),
      links: {
        linkedin: {
          label: I18n.t("home.index.links.linkedin.label"),
          href: I18n.t("home.index.links.linkedin.url")
        },
        calendar: {
          label: I18n.t("home.index.links.calendar.label"),
          href: I18n.t("home.index.links.calendar.url")
        }
      }
    }
  end

  private

  def current_nav_key
    "home"
  end

  def repository
    @repository ||= Blog::PostRepository.new
  end

  def preview_enabled?
    Rails.env.development? || Rails.env.test?
  end
end
