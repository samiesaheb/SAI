class LawVotesController < ApplicationController
  before_action :require_login
  before_action :set_community
  before_action :set_law
  before_action :require_membership

  def create
    @post_vote = @post.post_votes.find_or_initialize_by(user: current_user)
    new_value = params[:value].to_i

    # If trying to set to 0 (remove/neutral) but no vote exists yet, do nothing
    if new_value == 0 && !@post_vote.persisted?
      respond_to do |format|
        format.html { redirect_to community_post_path(@community, @post) }
        format.turbo_stream { head :ok }
      end
      return
    end

    # If the vote exists and the value hasn't changed, do nothing
    if @post_vote.persisted? && @post_vote.value == new_value
      respond_to do |format|
        format.html { redirect_to community_post_path(@community, @post) }
        format.turbo_stream { head :ok }
      end
      return
    end

  private

  def set_community
    @community = Community.find_by!(slug: params[:community_slug])
  end

  def set_law
    @law = @community.laws.find(params[:law_id])
  end

  def require_membership
    unless current_user.member_of?(@community)
      flash[:alert] = "You must be a member to vote."
      redirect_to community_path(@community)
    end
  end
end
