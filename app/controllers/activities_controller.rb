class ActivitiesController < ApplicationController
  before_action :require_login

  PER_PAGE = 20

  def index
    @page = (params[:page] || 1).to_i
    @activities = Activity.feed_for(current_user)
                          .offset((@page - 1) * PER_PAGE)
                          .limit(PER_PAGE + 1)

    @has_more = @activities.size > PER_PAGE
    @activities = @activities.first(PER_PAGE)
  end
end
