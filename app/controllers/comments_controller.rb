class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_community
  before_action :require_membership
  before_action :set_commentable

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.author = current_user
    @comment.community = @community

    if @comment.save
      membership = current_user.memberships.find_by(community: @community)
      membership&.award(:comment_created)
      redirect_to polymorphic_path([@community, @commentable]), notice: "Comment posted."
    else
      redirect_to polymorphic_path([@community, @commentable]), alert: @comment.errors.full_messages.first
    end
  end

  def destroy
    @comment = @commentable.comments.find(params[:id])

    if @comment.author == current_user || current_user.admin_of?(@community)
      @comment.destroy
      redirect_to polymorphic_path([@community, @commentable]), notice: "Comment deleted."
    else
      redirect_to polymorphic_path([@community, @commentable]), alert: "You can only delete your own comments."
    end
  end

  private

  def set_community
    @community = Community.find_by!(slug: params[:community_slug])
  end

  def require_membership
    unless current_user.member_of?(@community)
      flash[:alert] = "You must be a member to comment."
      redirect_to community_path(@community)
    end
  end

  def set_commentable
    if params[:post_id]
      @commentable = @community.posts.find(params[:post_id])
    elsif params[:meme_id]
      @commentable = @community.memes.find(params[:meme_id])
    end
  end

  def comment_params
    params.require(:comment).permit(:body, :parent_id)
  end
end
