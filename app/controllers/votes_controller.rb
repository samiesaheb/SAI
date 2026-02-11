class VotesController < ApplicationController
  before_action :require_login
  before_action :set_community
  before_action :set_proposal
  before_action :require_membership

  def create
    @vote = @proposal.votes.find_or_initialize_by(user: current_user)
    @vote.value = params[:value]

    respond_to do |format|
      if @vote.save
        format.html do
          redirect_to community_proposal_path(@community, @proposal), 
                      notice: "Vote recorded: #{params[:value].capitalize}"
        end
        format.turbo_stream # Looks for create.turbo_stream.erb
      else
        format.html do
          redirect_to community_proposal_path(@community, @proposal), 
                      alert: @vote.errors.full_messages.to_sentence
        end
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("vote-error", 
                partial: "shared/errors", locals: { object: @vote })
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
