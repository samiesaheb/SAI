class LawsController < ApplicationController
  before_action :set_community

  def index
    @laws = @community.laws.by_date.includes(:proposal, :law_votes)
  end

  def show
    @law = @community.laws.find(params[:id])
  end

  private

  def set_community
    @community = Community.find_by!(slug: params[:community_slug])
  end
end
