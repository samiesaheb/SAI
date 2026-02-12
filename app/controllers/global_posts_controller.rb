class GlobalPostsController < ApplicationController
  before_action :require_login
  before_action :load_sidebar_communities

  def index
    @category = params[:category]
    @sort = params[:sort] || "score"
    @posts = Post.approved.or(Post.canon)
    @posts = @posts.by_category(@category) if @category.present?

    @posts = case @sort
    when "quality"
      @posts.by_quality
    when "recent"
      @posts.order(created_at: :desc)
    else
      @posts.by_score
    end

    @posts = @posts.includes(:community, :author, post_votes: { user: :memberships })
  end

  private

  def load_sidebar_communities
    @sidebar_communities = Community.includes(:memberships).order(:name)
  end
end
