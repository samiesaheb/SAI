class ScripturesController < ApplicationController
  def show
    @scripture = Scripture.canonical
    @active_amendments = @scripture.amendments.active.includes(:proposer, :votes)
    @past_amendments = @scripture.amendments.where.not(status: "voting")
                                 .order(created_at: :desc)
                                 .limit(10)
                                 .includes(:proposer)
  end
end
