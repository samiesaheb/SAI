class ScriptureAmendmentVote < ApplicationRecord
  belongs_to :scripture_amendment
  belongs_to :user

  validates :value, inclusion: { in: %w[yes no] }
  validates :user_id, uniqueness: { scope: :scripture_amendment_id, message: "has already voted on this amendment" }

  validate :amendment_must_be_active, on: :create

  def yes?
    value == "yes"
  end

  def no?
    value == "no"
  end

  private

  def amendment_must_be_active
    return unless scripture_amendment
    unless scripture_amendment.voting_active?
      errors.add(:base, "Voting has ended for this amendment")
    end
  end
end
