class MembershipsController < ApplicationController
  before_action :require_login

  def create
    @community = Community.find_by!(slug: params[:community_slug])

    if current_user.member_of?(@community)
      flash[:notice] = "You're already a member of #{@community.name}."
    else
      @community.memberships.create!(user: current_user, role: "member")
      flash[:notice] = "Welcome to #{@community.name}!"
    end

    redirect_to community_path(@community)
  end

  def destroy
    @community = Community.find_by!(slug: params[:community_slug])
    membership = current_user.memberships.find_by(community: @community)

    if membership.nil?
      flash[:alert] = "You're not a member of #{@community.name}."
    elsif membership.admin? && @community.memberships.admins.count == 1
      flash[:alert] = "You can't leave as the only admin. Transfer admin role first."
    else
      membership.destroy
      flash[:notice] = "You have left #{@community.name}."
    end

    redirect_to community_path(@community)
  end
end
