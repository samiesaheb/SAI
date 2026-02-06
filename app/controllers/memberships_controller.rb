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
end
