class MemeVotesController < ApplicationController
  before_action :require_login
  before_action :set_community
  before_action :set_meme
  before_action :require_membership

  def create
    @meme_vote = @meme.meme_votes.find_or_initialize_by(user: current_user)
    new_value = params[:value].to_i

    # If already voted with same value, do nothing
    if @meme_vote.persisted? && @meme_vote.value == new_value
      respond_to do |format|
        format.html { redirect_to community_meme_path(@community, @meme) }
        format.turbo_stream { head :ok }
      end
      return
    end

    # Otherwise save the new vote (or update existing)
    @meme_vote.value = new_value
    @meme_vote.save

    respond_to do |format|
      format.html { redirect_to community_meme_path(@community, @meme) }
      format.turbo_stream
    end
  end

  private

  def set_community
    @community = Community.find_by!(slug: params[:community_slug])
  end

  def set_meme
    @meme = @community.memes.find(params[:meme_id])
  end

  def require_membership
    unless current_user.member_of?(@community)
      flash[:alert] = "You must be a member to vote."
      redirect_to community_path(@community)
    end
  end
end
