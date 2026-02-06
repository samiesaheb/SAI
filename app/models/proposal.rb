class Proposal < ApplicationRecord
  include Trackable
  track_creation :proposal_created

  belongs_to :community
  belongs_to :author, class_name: "User"
  has_many :votes, dependent: :destroy
  has_one :law, dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :body, presence: true, length: { maximum: 10_000 }
  validates :status, inclusion: { in: %w[voting passed failed] }
  validates :voting_ends_at, presence: true

  before_validation :set_voting_end_time, on: :create

  scope :active, -> { where(status: "voting").where("voting_ends_at > ?", Time.current) }
  scope :ended, -> { where(status: "voting").where("voting_ends_at <= ?", Time.current) }

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

  def abstain_votes
    votes.where(value: "abstain").count
  end

  def total_votes
    votes.count
  end

  # Weighted vote counts
  def weighted_yes_votes
    votes.where(value: "yes").includes(user: :memberships).sum do |vote|
      membership = vote.user.memberships.find_by(community: community)
      membership&.vote_weight || 1.0
    end.round(1)
  end

  def weighted_no_votes
    votes.where(value: "no").includes(user: :memberships).sum do |vote|
      membership = vote.user.memberships.find_by(community: community)
      membership&.vote_weight || 1.0
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

  def decisive_votes
    yes_votes + no_votes
  end

  def quorum_met?
    member_count = community.member_count
    return false if member_count.zero?
    participation_rate = (total_votes.to_f / member_count * 100)
    participation_rate >= community.quorum_percentage
  end

  def consensus_reached?
    yes_percentage >= community.consensus_threshold
  end

  def finalize!
    return unless voting_ended? && status == "voting"

    passed = quorum_met? && consensus_reached?

    if passed
      update!(status: "passed")
      create_law!
      track_activity(:proposal_passed, user: author)
    else
      update!(status: "failed")
      track_activity(:proposal_failed, user: author)
    end

    # Award/penalize author reputation
    author_membership = author.memberships.find_by(community: community)
    author_membership&.award(passed ? :proposal_passed : :proposal_failed)

    # Award reputation to voters who voted with majority
    award_voter_reputation(passed)
  end

  def user_vote(user)
    votes.find_by(user: user)
  end

  def time_remaining
    return nil unless voting_active?
    voting_ends_at - Time.current
  end

  private

  def set_voting_end_time
    return if voting_ends_at.present?
    self.voting_ends_at = Time.current + community.voting_period_days.days
  end

  def create_law!
    existing_laws_count = community.laws.where(title: title).count
    Law.create!(
      community: community,
      proposal: self,
      title: title,
      body: body,
      version: existing_laws_count + 1,
      passed_at: Time.current
    )
  end

  def award_voter_reputation(proposal_passed)
    winning_vote = proposal_passed ? "yes" : "no"

    votes.each do |vote|
      next if vote.value == "abstain"

      membership = vote.user.memberships.find_by(community: community)
      next unless membership

      if vote.value == winning_vote
        membership.award(:vote_with_majority)
      else
        membership.award(:vote_against_majority)
      end
    end
  end
end
