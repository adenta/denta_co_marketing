class BlogPostsController < ApplicationController
  allow_unauthenticated_access

  def index
    @posts = repository.published_posts(include_drafts: preview_enabled?)
  end

  def show
    @post = repository.published_post_by_slug!(params[:slug], include_drafts: preview_enabled?)
    ahoy.track "Viewed blog post", slug: @post.slug, title: @post.title
    @related_posts = related_posts_for(@post)
  end

  private

  def repository
    @repository ||= Blog::PostRepository.new
  end

  def related_posts_for(post)
    repository.published_posts(include_drafts: preview_enabled?)
      .reject { |candidate| candidate.slug == post.slug }
      .reject(&:draft?)
      .sort_by do |candidate|
        [ shared_tag_count(post, candidate), candidate.published_on ]
      end
      .reverse
      .first(3)
  end

  def shared_tag_count(left, right)
    (left.tags & right.tags).size
  end

  def preview_enabled?
    Rails.env.development? || Rails.env.test?
  end
end
