class ScriptureAmendmentsController < ApplicationController
  before_action :require_login, only: [:new, :create]
  before_action :set_scripture

  def show
    @amendment = @scripture.amendments.find(params[:id])
    @user_vote = current_user ? @amendment.user_vote(current_user) : nil
  end

  def new
    unless current_user.credible_for_scripture?
      redirect_to scripture_path, alert: "You need trusted reputation in at least one community to propose amendments."
      return
    end
    @amendment = @scripture.amendments.build
  end

  def create
    unless current_user.credible_for_scripture?
      redirect_to scripture_path, alert: "You need trusted reputation in at least one community to propose amendments."
      return
    end

    @amendment = @scripture.amendments.build(amendment_params)
    @amendment.proposer = current_user

    if @amendment.save
      redirect_to scripture_scripture_amendment_path(@scripture, @amendment), notice: "Amendment proposed! Voting is now open."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_scripture
    @scripture = Scripture.canonical
  end

  def amendment_params
    params.require(:scripture_amendment).permit(:title, :rationale, :proposed_content)
  end
end
