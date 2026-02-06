class FinalizeProposalsJob < ApplicationJob
  queue_as :default

  def perform
    Proposal.ended.find_each do |proposal|
      proposal.finalize!
    end
  end
end
