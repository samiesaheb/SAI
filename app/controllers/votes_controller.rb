class VotesController < ApplicationController
  before_action :require_login
  before_action :set_community
  before_action :set_proposal
  before_action :require_membership

  def create
    @vote = @proposal.votes.find_or_initialize_by(user: current_user)
    @vote.value = params[:value]

    if @vote.save
      respond_to do |format|
        format.html do
          flash[:notice] = "Vote recorded: #{params[:value].capitalize}"
          redirect_to community_proposal_path(@community, @proposal)
        end
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html do
          flash[:alert] = @vote.errors.full_messages.join(", ")
          redirect_to community_proposal_path(@community, @proposal)
        end
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace("vote-error",
            "<div id='vote-error' class='error'>#{@vote.errors.full_messages.join(', ')}</div>")
        end
      end
    end
  end

  private

  def set_community
    @community = Community.find_by!(slug: params[:community_slug])
  end

  def set_proposal
    @proposal = @community.proposals.find(params[:proposal_id])
  end

  def require_membership
    unless current_user.member_of?(@community)
      flash[:alert] = "You must be a member to vote."
      redirect_to community_path(@community)
    end
  end
end
