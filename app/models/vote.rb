class Vote < ApplicationRecord
  belongs_to :proposal
  belongs_to :user

  validates :value, inclusion: { in: %w[yes no abstain] }
  validates :user_id, uniqueness: { scope: :proposal_id, message: "has already voted on this proposal" }
  validate :proposal_must_be_active, on: :create
  validate :user_must_be_member

  def yes?
    value == "yes"
  end

  def no?
    value == "no"
  end

  def abstain?
    value == "abstain"
  end

  private

  def proposal_must_be_active
    return unless proposal
    unless proposal.voting_active?
      errors.add(:base, "Voting has ended for this proposal")
    end
  end

  def user_must_be_member
    return unless proposal && user
    unless user.member_of?(proposal.community)
      errors.add(:base, "You must be a member of the community to vote")
    end
  end
end
