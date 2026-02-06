class LawVotesController < ApplicationController
  before_action :require_login
  before_action :set_community
  before_action :set_law
  before_action :require_membership

  def create
    @law_vote = @law.law_votes.find_or_initialize_by(user: current_user)
    new_value = params[:value].to_i

    # If already voted with same value, do nothing
    if @law_vote.persisted? && @law_vote.value == new_value
      respond_to do |format|
        format.html { redirect_to community_law_path(@community, @law) }
        format.turbo_stream { head :ok }
      end
      return
    end

    # Otherwise save the new vote (or update existing)
    @law_vote.value = new_value
    @law_vote.save

    respond_to do |format|
      format.html { redirect_to community_law_path(@community, @law) }
      format.turbo_stream
    end
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
