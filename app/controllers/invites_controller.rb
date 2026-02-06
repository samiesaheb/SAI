class InvitesController < ApplicationController
  def show
    @community = Community.find_by!(invite_token: params[:token])

    if logged_in?
      if current_user.member_of?(@community)
        flash[:notice] = "You're already a member of #{@community.name}."
        redirect_to community_path(@community)
      else
        @community.memberships.create!(user: current_user, role: "member")
        flash[:notice] = "Welcome to #{@community.name}!"
        redirect_to community_path(@community)
      end
    else
      session[:pending_invite_token] = params[:token]
      flash[:notice] = "Sign up or log in to join #{@community.name}."
      redirect_to signup_path
    end
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Invalid invite link."
    redirect_to root_path
  end
end
