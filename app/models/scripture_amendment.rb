class ScriptureAmendment < ApplicationRecord
  belongs_to :scripture
  belongs_to :proposer, class_name: "User", foreign_key: :user_id
  has_many :votes, class_name: "ScriptureAmendmentVote", dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :rationale, presence: true, length: { maximum: 2000 }
  validates :proposed_content, presence: true, length: { maximum: 50_000 }
  validates :status, inclusion: { in: %w[voting passed failed] }
  validates :voting_ends_at, presence: true

  before_validation :set_voting_end_time, on: :create

  scope :active, -> { where(status: "voting").where("voting_ends_at > ?", Time.current) }
  scope :ended, -> { where.not(status: "voting").or(where("voting_ends_at <= ?", Time.current)) }

  def voting_active?
    status == "voting" && voting_ends_at > Time.current
  end

  def voting_ended?
    voting_ends_at <= Time.current
  end

  def yes_votes
    votes.where(value: "yes").count
  end

  def no_votes
    votes.where(value: "no").count
  end

  def total_votes
    votes.count
  end

  def weighted_yes_votes
    votes.where(value: "yes").includes(user: :memberships).sum do |vote|
      vote.user.scripture_vote_weight
    end.round(1)
  end

  def weighted_no_votes
    votes.where(value: "no").includes(user: :memberships).sum do |vote|
      vote.user.scripture_vote_weight
    end.round(1)
  end

  def weighted_decisive_votes
    weighted_yes_votes + weighted_no_votes
  end

  def yes_percentage
    return 0 if weighted_decisive_votes.zero?
    (weighted_yes_votes / weighted_decisive_votes * 100).round(1)
  end

  def no_percentage
    return 0 if weighted_decisive_votes.zero?
    (weighted_no_votes / weighted_decisive_votes * 100).round(1)
  end

  def quorum_met?
    total_votes >= 3
  end

  def consensus_reached?
    yes_percentage >= 60.0
  end

  def user_vote(user)
    votes.find_by(user: user)
  end

  def finalize!
    return unless voting_ended? && status == "voting"

    passed = quorum_met? && consensus_reached?

    if passed
      update!(status: "passed")
      scripture.update!(
        content: proposed_content,
        version: scripture.version + 1,
        updated_by: proposer
      )
    else
      update!(status: "failed")
    end
  end

  private

  def set_voting_end_time
    return if voting_ends_at.present?
    self.voting_ends_at = Time.current + 7.days
  end
end
