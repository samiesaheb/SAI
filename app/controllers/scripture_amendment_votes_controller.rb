class ScriptureAmendmentVotesController < ApplicationController
  before_action :require_login
  before_action :set_amendment

  def create
    @vote = @amendment.votes.find_or_initialize_by(user: current_user)
    @vote.value = params[:value]

    respond_to do |format|
      if @vote.save
        @amendment.finalize! if @amendment.voting_ended?

        format.html do
          redirect_to scripture_scripture_amendment_path(@scripture, @amendment),
                      notice: "Vote recorded: #{params[:value].capitalize}"
        end
        format.turbo_stream
      else
        format.html do
          redirect_to scripture_scripture_amendment_path(@scripture, @amendment),
                      alert: @vote.errors.full_messages.to_sentence
        end
        format.turbo_stream do
          render turbo_stream: turbo_stream.update("vote-error",
                partial: "shared/errors", locals: { object: @vote })
        end
      end
    end
  end

  private

  def set_amendment
    @scripture = Scripture.canonical
    @amendment = @scripture.amendments.find(params[:scripture_amendment_id])
  end
end
