class CommunitiesController < ApplicationController
  before_action :require_login, except: [:show]
  before_action :set_community, only: [:show, :edit, :update, :destroy]
  before_action :require_admin, only: [:edit, :update, :destroy]

  def index
    @my_communities = current_user.communities.includes(:memberships)
    @other_communities = Community.where.not(id: @my_communities.pluck(:id)).includes(:memberships)
  end

  def show
    @is_member = logged_in? && current_user.member_of?(@community)
    @active_proposals = @community.active_proposals.includes(:author, :votes) if @is_member
    @laws = @community.laws.by_date.limit(5) if @is_member
  end

  def new
    @community = Community.new
  end

  def create
    @community = Community.new(community_params)
    @community.creator = current_user

    if @community.save
      flash[:notice] = "Community created successfully!"
      redirect_to community_path(@community)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @community.update(community_params)
      flash[:notice] = "Community updated successfully."
      redirect_to community_path(@community)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @community.destroy
    flash[:notice] = "Community has been deleted."
    redirect_to communities_path
  end

  private

  def set_community
    @community = Community.find_by!(slug: params[:slug])
  end

  def require_admin
    unless current_user&.admin_of?(@community)
      flash[:alert] = "You must be an admin to perform this action."
      redirect_to community_path(@community)
    end
  end

  def community_params
    params.require(:community).permit(:name, :description, :category, :consensus_threshold, :quorum_percentage, :voting_period_days)
  end
end
