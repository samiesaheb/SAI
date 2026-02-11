class Meme < ApplicationRecord
  include Trackable
  track_creation :meme_created

  CATEGORIES = %w[psychology psychedelics religion].freeze
  STATUSES = %w[pending approved canon rejected].freeze
  CANON_THRESHOLD = 10 # Score needed to become canon

  belongs_to :community
  belongs_to :author, class_name: "User"
  has_many :meme_votes, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :proposal_memes, dependent: :destroy
  has_many :proposals, through: :proposal_memes
  has_one_attached :image

  attr_accessor :image_url

  validates :title, presence: true, length: { maximum: 200 }
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }
  validate :image_present_on_create, on: :create

  before_validation :attach_image_from_url, if: -> { image_url.present? }

  def attach_image_from_url
    return if image_url.blank?

    require "open-uri"
    begin
      uri = URI.parse(image_url)

      downloaded_image = uri.open
      content_type = downloaded_image.content_type

      # Validate that the URL returns an actual image
      unless content_type&.start_with?("image/")
        errors.add(:image_url, "must be a direct link to an image file (e.g., ending in .jpg, .png, .gif). The URL provided is a webpage, not an image.")
        return
      end

      # Generate filename from URL or create one
      filename = File.basename(uri.path).presence || "image_#{SecureRandom.hex(4)}"
      extension = content_type.split("/").last.gsub("jpeg", "jpg")
      filename = "#{filename}.#{extension}" unless filename.match?(/\.(jpg|jpeg|png|gif|webp)$/i)

      image.attach(io: downloaded_image, filename: filename, content_type: content_type)
    rescue URI::InvalidURIError
      errors.add(:image_url, "is not a valid URL")
    rescue OpenURI::HTTPError => e
      errors.add(:image_url, "could not be accessed: #{e.message}")
    rescue StandardError => e
      errors.add(:image_url, "could not be downloaded: #{e.message}")
    end
  end

  private

  def image_present_on_create
    unless image.attached? || image_url.present?
      errors.add(:image, "must be uploaded or provided via URL")
    end
  end

  public

  scope :pending, -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :canon, -> { where(status: "canon") }
  scope :by_score, -> { left_joins(:meme_votes).group(:id).order(Arel.sql("COALESCE(SUM(meme_votes.value), 0) DESC")) }
  scope :by_category, ->(cat) { where(category: cat) }
  scope :unlocked, -> { where("locked_until_block IS NULL OR locked_until_block <= ?", Block.current_height) }

  def upvotes
    meme_votes.where(value: 1).count
  end

  def downvotes
    meme_votes.where(value: -1).count
  end

  # Raw score (unweighted)
  def raw_score
    meme_votes.sum(:value)
  end

  # Weighted score based on voter reputation
  def score
    meme_votes.to_a.sum do |vote|
      weight = vote.user&.memberships&.find { |m| m.community_id == community_id }&.vote_weight || 1.0
      vote.value * weight
    end.round(1)
  end

  def weighted_upvotes
    meme_votes.to_a.select { |v| v.value == 1 }.sum do |vote|
      vote.user&.memberships&.find { |m| m.community_id == community_id }&.vote_weight || 1.0
    end.round(1)
  end

  def weighted_downvotes
    meme_votes.to_a.select { |v| v.value == -1 }.sum do |vote|
      vote.user&.memberships&.find { |m| m.community_id == community_id }&.vote_weight || 1.0
    end.round(1)
  end

  def user_vote(user)
    return nil unless user
    meme_votes.to_a.find { |v| v.user_id == user.id }
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

  def blocks_until_unlock
    return 0 unless locked?
    locked_until_block - Block.current_height
  end

  def time_until_unlock
    Block.time_until(locked_until_block)
  end

  def check_canon!
    meme_votes.reset
    return unless status == "approved" && score >= CANON_THRESHOLD
    update!(status: "canon", canon_at: Time.current)

    # Award reputation to author
    author_membership = author.memberships.find_by(community: community)
    author_membership&.award(:meme_canon)

    track_activity(:meme_canon, user: author)
  end

  def category_emoji
    case category
    when "psychology" then "🧠"
    when "psychedelics" then "🍄"
    when "religion" then "🕉️"
    else "📜"
    end
  end

  def category_label
    "#{category_emoji} #{category.titleize}"
  end
end
