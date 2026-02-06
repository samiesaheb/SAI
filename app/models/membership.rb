class Membership < ApplicationRecord
  include Trackable

  after_create_commit :track_join_activity

  REPUTATION_LEVELS = {
    "newcomer" => { min: 0, weight: 1.0 },
    "member" => { min: 10, weight: 1.5 },
    "trusted" => { min: 50, weight: 2.0 },
    "veteran" => { min: 100, weight: 2.5 },
    "elder" => { min: 250, weight: 3.0 }
  }.freeze

  REPUTATION_REWARDS = {
    proposal_passed: 10,
    proposal_failed: -2,
    meme_canon: 15,
    meme_approved: 2,
    post_canon: 15,
    post_approved: 3,
    post_vote_with_majority: 1,
    vote_with_majority: 1,
    vote_against_majority: -1,
    comment_created: 1,
    daily_participation: 1
  }.freeze

  belongs_to :user
  belongs_to :community

  validates :user_id, uniqueness: { scope: :community_id, message: "is already a member of this community" }
  validates :role, inclusion: { in: %w[member admin] }
  validates :reputation_level, inclusion: { in: REPUTATION_LEVELS.keys }

  before_create :set_joined_at
  before_save :update_reputation_level

  scope :admins, -> { where(role: "admin") }
  scope :members, -> { where(role: "member") }
  scope :by_reputation, -> { order(reputation: :desc) }

  def admin?
    role == "admin"
  end

  def vote_weight
    REPUTATION_LEVELS[reputation_level][:weight]
  end

  def add_reputation(amount, reason = nil)
    new_rep = [reputation + amount, 0].max # Can't go below 0
    update!(reputation: new_rep)
    Rails.logger.info "#{user.username} #{amount >= 0 ? 'gained' : 'lost'} #{amount.abs} rep in #{community.name}: #{reason}"
  end

  def award(reward_type)
    amount = REPUTATION_REWARDS[reward_type]
    add_reputation(amount, reward_type.to_s.humanize) if amount
  end

  def level_progress
    current_level = REPUTATION_LEVELS[reputation_level]
    next_level = REPUTATION_LEVELS.values.find { |l| l[:min] > reputation }
    return 100 unless next_level

    range = next_level[:min] - current_level[:min]
    progress = reputation - current_level[:min]
    ((progress.to_f / range) * 100).round
  end

  def next_level_at
    next_level = REPUTATION_LEVELS.find { |_, v| v[:min] > reputation }
    next_level ? next_level[1][:min] : nil
  end

  def level_emoji
    case reputation_level
    when "newcomer" then "🌱"
    when "member" then "👤"
    when "trusted" then "⭐"
    when "veteran" then "🏆"
    when "elder" then "👑"
    else "🌱"
    end
  end

  private

  def set_joined_at
    self.joined_at ||= Time.current
  end

  def update_reputation_level
    new_level = REPUTATION_LEVELS.to_a.reverse.find { |_, v| reputation >= v[:min] }&.first || "newcomer"
    self.reputation_level = new_level
  end

  def track_join_activity
    Activity.create(
      user: user,
      community: community,
      trackable: self,
      action: "user_joined",
      metadata: {}
    )
  rescue StandardError => e
    Rails.logger.error "Failed to track join activity: #{e.message}"
  end
end
