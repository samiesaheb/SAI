class PostVotesController < ApplicationController
  before_action :require_login
  before_action :set_community
  before_action :set_post
  before_action :require_membership

  def create
    @post_vote = @post.post_votes.find_or_initialize_by(user: current_user)
    new_value = params[:value].to_i

    if @post_vote.persisted? && @post_vote.value == new_value
      # Toggle off: same button clicked again
      @post_vote.destroy
    elsif @post_vote.persisted?
      # Switch vote direction
      @post_vote.update!(value: new_value)
    else
      # New vote
      @post_vote.value = new_value
      @post_vote.save!
    end

    # Load a completely fresh post with all vote data preloaded
    @post = Post.includes(post_votes: { user: :memberships }).find(@post.id)

    respond_to do |format|
      format.html { redirect_to community_post_path(@community, @post) }
      format.turbo_stream
    end
  end

  private

  def set_community
    @community = Community.find_by!(slug: params[:community_slug])
  end

  def set_post
    @post = @community.posts.find(params[:post_id])
  end

  def require_membership
    unless current_user.member_of?(@community)
      flash[:alert] = "You must be a member to vote."
      redirect_to community_path(@community)
    end
  end
end
