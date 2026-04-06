class WritingsController < ApplicationController
  allow_unauthenticated_access

  def index
    posts = repository.published_posts(include_drafts: preview_enabled?)

    return unless cache_public_page!(
      etag: [ "blog-index", I18n.locale, preview_enabled?, posts.map { |post| [ post.slug, post.source_updated_at&.to_i ] } ],
      last_modified: [ translations_last_updated_at, repository.latest_updated_at(include_drafts: preview_enabled?) ].compact.max,
    )

    @page_meta = {
      title: "Writing | #{I18n.t("site.meta.default_title", default: "Andrew Denta")}",
      description: "Writing."
    }
    @props = {
      posts: PostBlueprint.render_as_hash(posts),
      subscribeForm: {
        createPath: api_v1_blog_subscriptions_path,
        title: I18n.t("blog_subscriptions.card.title"),
        description: I18n.t("blog_subscriptions.card.description"),
        emailLabel: I18n.t("blog_subscriptions.card.email_label"),
        emailPlaceholder: I18n.t("blog_subscriptions.card.email_placeholder"),
        submitLabel: I18n.t("blog_subscriptions.card.submit_label"),
        successMessage: I18n.t("blog_subscriptions.card.success_message"),
        subscribedTitle: I18n.t("blog_subscriptions.card.subscribed_title"),
        subscribedDescription: I18n.t("blog_subscriptions.card.subscribed_description"),
        resetLabel: I18n.t("blog_subscriptions.card.reset_label"),
        turnstileSiteKey: ENV["CLOUDFLARE_TURNSTILE_SITE_KEY"],
        verificationRequiredMessage: I18n.t("blog_subscriptions.card.verification_required"),
        unavailableMessage: I18n.t("blog_subscriptions.card.unavailable")
      }
    }
  end

  private

  def current_nav_key
    "writing"
  end

  def repository
    @repository ||= Blog::PostRepository.new
  end

  def preview_enabled?
    Rails.env.development? || Rails.env.test?
  end
end
