class SeoController < ApplicationController
  allow_unauthenticated_access
  CACHE_TTL = 24.hours

  def feed
    posts = repository.published_posts.first(20)

    expires_in CACHE_TTL, public: true, stale_while_revalidate: 5.minutes
    render body: Rails.cache.fetch(feed_cache_key(posts), expires_in: CACHE_TTL) {
      @posts = posts
      @feed_updated_at = (posts.first&.source_updated_at || posts.first&.published_on || Date.current).in_time_zone
      render_to_string(template: "seo/feed", formats: :xml, handlers: [ :builder ], layout: false)
    }, content_type: "application/atom+xml"
  end

  def sitemap
    posts = repository.published_posts
    latest_updated_at = posts.filter_map(&:source_updated_at).max || posts.max_by(&:published_on)&.published_on&.in_time_zone

    expires_in CACHE_TTL, public: true, stale_while_revalidate: 5.minutes
    render body: Rails.cache.fetch(sitemap_cache_key(posts), expires_in: CACHE_TTL) {
      @posts = posts
      @latest_publication_date = latest_updated_at
      render_to_string(template: "seo/sitemap", formats: :xml, handlers: [ :builder ], layout: false)
    }, content_type: "application/xml"
  end

  def robots
    expires_in CACHE_TTL, public: true, stale_while_revalidate: 5.minutes
    render plain: Rails.cache.fetch(robots_cache_key, expires_in: CACHE_TTL) {
      <<~ROBOTS
        User-agent: *
        Allow: /

        Sitemap: #{helpers.absolute_page_url(sitemap_path(format: :xml))}
      ROBOTS
    }, content_type: "text/plain"
  end

  private

  def repository
    @repository ||= Blog::PostRepository.new
  end

  def feed_cache_key(posts)
    [ "seo", "feed", posts.map { |post| [ post.slug, post.source_updated_at&.to_i, post.published_on.iso8601 ] } ]
  end

  def sitemap_cache_key(posts)
    [ "seo", "sitemap", posts.map { |post| [ post.slug, post.source_updated_at&.to_i, post.published_on.iso8601 ] } ]
  end

  def robots_cache_key
    [ "seo", "robots", Rails.application.routes.default_url_options.symbolize_keys.slice(:protocol, :host, :port) ]
  end
end
