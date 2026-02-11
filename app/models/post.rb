class Post < ApplicationRecord
  include Trackable
  track_creation :post_created

  CATEGORIES = %w[psychology psychedelics religion philosophy science politics economics technology art other].freeze
  STATUSES = %w[pending approved canon rejected].freeze
  CANON_THRESHOLD = 15
  MAX_CHAR_COUNT = 100

  belongs_to :community
  belongs_to :author, class_name: "User"
  has_many :post_votes, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  validates :title, presence: true, length: { maximum: 200 }
  validates :body, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }
  validates :body, length: { maximum: MAX_CHAR_COUNT, message: "must be at most #{MAX_CHAR_COUNT} characters" }

  before_validation :calculate_word_count
  before_create :classify_content
  before_create :stamp_bitcoin_block

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :canon, -> { where(status: "canon") }
  scope :by_score, -> { left_joins(:post_votes).group(:id).order(Arel.sql("COALESCE(SUM(post_votes.value), 0) DESC")) }
  scope :by_category, ->(cat) { cat.present? ? where(category: cat) : all }
  scope :by_quality, -> { order(quality_score: :desc) }

  def upvotes
    post_votes.where(value: 1).count
  end

  def downvotes
    post_votes.where(value: -1).count
  end

  def raw_score
    post_votes.sum(:value)
  end

  def score
    # Use to_a to leverage preloaded post_votes if available
    post_votes.to_a.sum do |vote|
      weight = vote.user&.memberships&.find { |m| m.community_id == community_id }&.vote_weight || 1.0
      vote.value * weight
    end.round(1)
  end

  def weighted_upvotes
    post_votes.to_a.select { |v| v.value == 1 }.sum do |vote|
      vote.user&.memberships&.find { |m| m.community_id == community_id }&.vote_weight || 1.0
    end.round(1)
  end

  def weighted_downvotes
    post_votes.to_a.select { |v| v.value == -1 }.sum do |vote|
      vote.user&.memberships&.find { |m| m.community_id == community_id }&.vote_weight || 1.0
    end.round(1)
  end

  def user_vote(user)
    return nil unless user
    # Use find to leverage preloaded post_votes if available
    post_votes.to_a.find { |v| v.user_id == user.id }
  end

  def locked?
    locked_until_block.present? && locked_until_block > Block.current_height
  end

  def canon?
    status == "canon"
  end

  def approved?
    status == "approved"
  end

  def pending?
    status == "pending"
  end

  def check_canon!
    post_votes.reset
    return unless status == "approved" && score >= CANON_THRESHOLD
    update!(status: "canon", canon_at: Time.current)

    author_membership = author.memberships.find_by(community: community)
    author_membership&.award(:post_canon)

    track_activity(:post_canon, user: author)
  end

  def parsed_sources
    return [] if sources.blank?
    JSON.parse(sources)
  rescue JSON::ParserError
    []
  end

  def category_emoji
    case category
    when "psychology" then "🧠"
    when "psychedelics" then "🍄"
    when "religion" then "🕉️"
    when "philosophy" then "💭"
    when "science" then "🔬"
    when "politics" then "🏛️"
    when "economics" then "📊"
    when "technology" then "💻"
    when "art" then "🎨"
    when "other" then "📝"
    else "📜"
    end
  end

  def category_label
    "#{category_emoji} #{category.titleize}"
  end

  private

  def calculate_word_count
    self.word_count = body.to_s.split(/\s+/).reject(&:blank?).size
  end

  def classify_content
    result = PostClassifierService.classify(body)
    self.ml_category = result[:category]
    self.quality_score = result[:quality_score]
  rescue => e
    Rails.logger.error "Post classification failed: #{e.message}"
    self.ml_category = nil
    self.quality_score = 0.0
  end

  def stamp_bitcoin_block
    block_data = BitcoinBlockService.current_block
    self.bitcoin_block_height = block_data[:height]
    self.bitcoin_block_hash = block_data[:hash]
  rescue => e
    Rails.logger.error "Bitcoin block stamp failed: #{e.message}"
  end
end
