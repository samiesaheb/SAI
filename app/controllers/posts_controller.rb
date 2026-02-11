class PostsController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :set_community
  before_action :require_membership, only: [:new, :create, :destroy]
  before_action :set_post, only: [:show, :destroy]

  def index
    @category = params[:category]
    @sort = params[:sort] || "score"
    @posts = @community.posts.approved.or(@community.posts.canon)
    @posts = @posts.by_category(@category) if @category.present?

    @posts = case @sort
    when "quality"
      @posts.by_quality
    when "recent"
      @posts.order(created_at: :desc)
    else
      @posts.by_score
    end

    @posts = @posts.includes(:author, post_votes: { user: :memberships })
    @canon_posts = @community.posts.canon.by_category(@category.presence).by_score.limit(5)
  end

  def show
    @user_vote = current_user ? @post.user_vote(current_user) : nil
    @is_member = current_user&.member_of?(@community)
    @comments = @post.comments.where(parent_id: nil)
                     .includes(:author, :comment_votes, replies: [:author, :comment_votes, replies: [:author, :comment_votes]])
                     .order(created_at: :desc)
  end

  def new
    @post = @community.posts.build
  end

  def create
    @post = @community.posts.build(post_params)
    @post.author = current_user
    @post.status = "approved"

    if params[:post][:sources_list].present?
      sources = params[:post][:sources_list].reject { |s| s[:url].blank? && s[:title].blank? }
      @post.sources = sources.to_json if sources.any?
    end

    if @post.save
      flash[:notice] = "Post published successfully!"
      redirect_to community_post_path(@community, @post)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if @post.author == current_user || current_user.admin_of?(@community)
      @post.destroy
      flash[:notice] = "Post deleted."
      redirect_to community_posts_path(@community)
    else
      flash[:alert] = "You can only delete your own posts."
      redirect_to community_post_path(@community, @post)
    end
  end

  private

  def set_community
    @community = Community.find_by!(slug: params[:community_slug])
  end

  def require_membership
    unless current_user.member_of?(@community)
      flash[:alert] = "You must be a member to view posts."
      redirect_to community_path(@community)
    end
  end

  def set_post
    @post = @community.posts.includes(post_votes: { user: :memberships }).find(params[:id])
  end

  def post_params
    params.require(:post).permit(:title, :category, :body)
  end
end
