class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    unless logged_in?
      flash[:alert] = "You must be logged in to access this page."
      redirect_to login_path
    end
  end

  def require_membership
    @community = Community.find_by!(slug: params[:community_id] || params[:id])
    unless current_user&.member_of?(@community)
      flash[:alert] = "You must be a member of this community."
      redirect_to community_path(@community)
    end
  end

  def require_admin
    @community = Community.find_by!(slug: params[:community_id] || params[:id])
    unless current_user&.admin_of?(@community)
      flash[:alert] = "You must be an admin to perform this action."
      redirect_to community_path(@community)
    end
  end
end
