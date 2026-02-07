class UsersController < ApplicationController
  def new
    redirect_to root_path if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "Welcome to Common Consensus!"

      # Handle pending invite
      if session[:pending_invite_token]
        redirect_to join_path(token: session.delete(:pending_invite_token))
      else
        redirect_to root_path
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @user = User.find_by!(username: params[:username])
    @memberships = @user.memberships.includes(:community).by_reputation
    @recent_posts = @user.posts.includes(:community).order(created_at: :desc).limit(5)
    @recent_memes = @user.memes.includes(:community, image_attachment: :blob).order(created_at: :desc).limit(6)
    @stats = {
      communities: @user.memberships.count,
      posts: @user.posts.count,
      memes: @user.memes.count,
      proposals: @user.proposals.count
    }
  end

  private

  def user_params
    params.require(:user).permit(:email, :username, :password, :password_confirmation, :display_name)
  end
end
