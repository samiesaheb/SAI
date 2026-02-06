class CommentVotesController < ApplicationController
  before_action :require_login
  before_action :set_community
  before_action :set_comment
  before_action :require_membership

  def create
    @comment_vote = @comment.comment_votes.find_or_initialize_by(user: current_user)
    new_value = params[:value].to_i

    if @comment_vote.persisted? && @comment_vote.value == new_value
      redirect_to polymorphic_path([@community, @comment.commentable])
      return
    end

    @comment_vote.value = new_value
    @comment_vote.save

    redirect_to polymorphic_path([@community, @comment.commentable])
  end

  private

  def set_community
    @community = Community.find_by!(slug: params[:community_slug])
  end

  def set_comment
    @comment = Comment.find(params[:comment_id])
  end

  def require_membership
    unless current_user.member_of?(@community)
      flash[:alert] = "You must be a member to vote."
      redirect_to community_path(@community)
    end
  end
end
