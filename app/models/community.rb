class Community < ApplicationRecord
  CATEGORIES = %w[general technology science politics philosophy religion psychology art economics health education gaming sports music entertainment travel food fitness business].freeze

  belongs_to :creator, class_name: "User"
  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships, source: :user
  has_many :proposals, dependent: :destroy
  has_many :laws, dependent: :destroy
  has_many :memes, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { case_sensitive: false }
  validates :slug, presence: true, uniqueness: true,
            format: { with: /\A[a-z0-9-]+\z/, message: "can only contain lowercase letters, numbers, and hyphens" }
  validates :consensus_threshold, numericality: { in: 50..100 }
  validates :quorum_percentage, numericality: { in: 1..100 }
  validates :voting_period_days, numericality: { in: 1..90 }
  validates :invite_token, presence: true, uniqueness: true
  validates :category, inclusion: { in: CATEGORIES }

  before_validation :generate_slug, on: :create
  before_validation :generate_invite_token, on: :create
  after_create :add_creator_as_admin

  def active_proposals
    proposals.where(status: "voting").where("voting_ends_at > ?", Time.current)
  end

  def passed_proposals
    proposals.where(status: "passed")
  end

  def failed_proposals
    proposals.where(status: "failed")
  end

  def member_count
    memberships.size
  end

  def to_param
    slug
  end

  def regenerate_invite_token!
    update!(invite_token: SecureRandom.urlsafe_base64(16))
  end

  private

  def generate_slug
    return if slug.present?
    base_slug = name.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/^-|-$/, "")
    self.slug = base_slug
    counter = 1
    while Community.exists?(slug: self.slug)
      self.slug = "#{base_slug}-#{counter}"
      counter += 1
    end
  end

  def generate_invite_token
    self.invite_token ||= SecureRandom.urlsafe_base64(16)
  end

  def add_creator_as_admin
    memberships.create!(user: creator, role: "admin", joined_at: Time.current)
  end
end
