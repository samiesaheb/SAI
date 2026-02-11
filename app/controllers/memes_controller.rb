class MemesController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :set_community
  before_action :require_membership, only: [:new, :create, :destroy]
  before_action :set_meme, only: [:show, :destroy]

  def index
    @category = params[:category]
    @memes = @community.memes.approved.or(@community.memes.canon)
    @memes = @memes.by_category(@category) if @category.present?
    @memes = @memes.by_score.includes(:author, meme_votes: { user: :memberships }, image_attachment: :blob)

    @canon_memes = @community.memes.canon.by_category(@category.presence).by_score.limit(5)
  end

  def show
    @user_vote = current_user ? @meme.user_vote(current_user) : nil
    @is_member = current_user&.member_of?(@community)
    @comments = @meme.comments.where(parent_id: nil)
                     .includes(:author, :comment_votes, replies: [:author, :comment_votes, replies: [:author, :comment_votes]])
                     .order(created_at: :desc)
  end

  def new
    @meme = @community.memes.build
  end

  def create
    @meme = @community.memes.build(meme_params)
    @meme.author = current_user
    @meme.status = "approved" # Auto-approve for MVP, could add moderation later

    if @meme.save
      flash[:notice] = "Meme uploaded successfully!"
      redirect_to community_meme_path(@community, @meme)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if @meme.author == current_user || current_user.admin_of?(@community)
      @meme.destroy
      flash[:notice] = "Meme deleted."
      redirect_to community_memes_path(@community)
    else
      flash[:alert] = "You can only delete your own memes."
      redirect_to community_meme_path(@community, @meme)
    end
  end

  private

  def set_community
    @community = Community.find_by!(slug: params[:community_slug])
  end

  def require_membership
    unless current_user.member_of?(@community)
      flash[:alert] = "You must be a member to view memes."
      redirect_to community_path(@community)
    end
  end

  def set_meme
    @meme = @community.memes.includes(meme_votes: { user: :memberships }).find(params[:id])
  end

  def meme_params
    params.require(:meme).permit(:title, :category, :image, :image_url)
  end
end
