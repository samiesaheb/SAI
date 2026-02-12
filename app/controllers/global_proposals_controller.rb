class GlobalProposalsController < ApplicationController
  before_action :load_sidebar_communities

  def index
    @active_proposals = Proposal.active.includes(:community, :author, :votes, :memes)
    @ended_proposals = Proposal.where.not(status: "voting")
                               .or(Proposal.ended)
                               .includes(:community, :author, :votes, :memes)
                               .order(voting_ends_at: :desc)
  end

  private

  def load_sidebar_communities
    @sidebar_communities = Community.includes(:memberships).order(:name)
  end
end
