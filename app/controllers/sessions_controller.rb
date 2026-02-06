class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by("lower(email) = ? OR lower(username) = ?",
                        params[:login].downcase, params[:login].downcase)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Welcome back, #{user.display_name_or_username}!"
      redirect_to params[:redirect_to] || root_path
    else
      flash.now[:alert] = "Invalid email/username or password."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session.delete(:user_id)
    @current_user = nil
    flash[:notice] = "You have been logged out."
    redirect_to root_path
  end
end
