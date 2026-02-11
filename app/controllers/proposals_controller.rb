class ProposalsController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :set_community
  before_action :require_membership, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_proposal, only: [:show, :edit, :update, :destroy]

  def index
    @active_proposals = @community.proposals.active.includes(:author, :votes, :memes)
    @ended_proposals = @community.proposals.where.not(status: "voting")
                                 .or(@community.proposals.ended)
                                 .includes(:author, :votes, :memes)
                                 .order(voting_ends_at: :desc)
  end

  def show
    @user_vote = current_user ? @proposal.user_vote(current_user) : nil
    @is_member = current_user&.member_of?(@community)
  end

  def new
    @proposal = @community.proposals.build
    @available_memes = @community.memes.where(status: %w[approved canon]).order(created_at: :desc)
  end

  def create
    @proposal = @community.proposals.build(proposal_params)
    @proposal.author = current_user

    if @proposal.save
      flash[:notice] = "Proposal submitted for voting!"
      redirect_to community_proposal_path(@community, @proposal)
    else
      @available_memes = @community.memes.where(status: %w[approved canon]).order(created_at: :desc)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    unless @proposal.author == current_user || current_user.admin_of?(@community)
      flash[:alert] = "You can only edit your own proposals."
      redirect_to community_proposal_path(@community, @proposal) and return
    end

    unless @proposal.voting_active?
      flash[:alert] = "Cannot edit a proposal after voting has ended."
      redirect_to community_proposal_path(@community, @proposal) and return
    end

    @available_memes = @community.memes.where(status: %w[approved canon]).order(created_at: :desc)
  end

  def update
    if @proposal.update(proposal_params)
      flash[:notice] = "Proposal updated."
      redirect_to community_proposal_path(@community, @proposal)
    else
      @available_memes = @community.memes.where(status: %w[approved canon]).order(created_at: :desc)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @proposal.author == current_user || current_user.admin_of?(@community)
      @proposal.destroy
      flash[:notice] = "Proposal withdrawn."
      redirect_to community_proposals_path(@community)
    else
      flash[:alert] = "You can only delete your own proposals."
      redirect_to community_proposal_path(@community, @proposal)
    end
  end

  private

  def set_community
    @community = Community.find_by!(slug: params[:community_slug])
  end

  def require_membership
    unless current_user.member_of?(@community)
      flash[:alert] = "You must be a member of this community."
      redirect_to community_path(@community)
    end
  end

  def set_proposal
    @proposal = @community.proposals.find(params[:id])
  end

  def proposal_params
    params.require(:proposal).permit(:title, :body, meme_ids: [])
  end
end
