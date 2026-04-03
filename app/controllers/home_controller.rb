class HomeController < ApplicationController
  def index
    recent_posts = repository.blog_posts(include_drafts: preview_enabled?).first(3)

    return unless cache_public_page!(
      etag: [ "home", I18n.locale, preview_enabled?, recent_posts.map { |post| [ post.slug, post.source_updated_at&.to_i ] } ],
      last_modified: [ translations_last_updated_at, repository.latest_updated_at(include_drafts: preview_enabled?) ].compact.max,
    )

    @page_meta = {
      title: I18n.t("site.meta.default_title", default: "Andrew Denta"),
      description: I18n.t("home.index.subtitle")
    }
    @props = {
      title: I18n.t("home.index.title"),
      subtitle: I18n.t("home.index.subtitle"),
      recentPostsHeading: I18n.t("home.index.recent_posts.heading"),
      recentPostsPath: blog_posts_path,
      recentPostsEmpty: I18n.t("home.index.recent_posts.empty"),
      recentPosts: PostBlueprint.render_as_hash(recent_posts),
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
