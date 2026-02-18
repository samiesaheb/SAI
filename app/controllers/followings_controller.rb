class FollowingsController < ApplicationController
  before_action :require_login
  before_action :set_user

  def create
    if current_user == @user
      redirect_to user_path(username: @user.username), alert: "You cannot follow yourself."
      return
    end

    current_user.followings.create!(following: @user)
    redirect_to user_path(username: @user.username), notice: "You are now following #{@user.display_name_or_username}."
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    redirect_to user_path(username: @user.username), alert: "Already following."
  end

  def destroy
    following = current_user.followings.find_by(following: @user)
    following&.destroy
    redirect_to user_path(username: @user.username), notice: "You unfollowed #{@user.display_name_or_username}."
  end

  private

  def set_user
    @user = User.find_by!(username: params[:username])
  end
end
