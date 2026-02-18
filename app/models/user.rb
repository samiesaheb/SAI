class User < ApplicationRecord
  has_secure_password

  has_many :memberships, dependent: :destroy
  has_many :communities, through: :memberships
  has_many :created_communities, class_name: "Community", foreign_key: :creator_id, dependent: :nullify
  has_many :proposals, foreign_key: :author_id, dependent: :nullify
  has_many :votes, dependent: :destroy
  has_many :memes, foreign_key: :author_id, dependent: :nullify
  has_many :meme_votes, dependent: :destroy
  has_many :posts, foreign_key: :author_id, dependent: :nullify
  has_many :post_votes, dependent: :destroy
  has_many :comments, foreign_key: :author_id, dependent: :destroy
  has_many :comment_votes, dependent: :destroy
  has_many :scripture_amendment_votes, dependent: :destroy

  has_many :followings, foreign_key: :follower_id, dependent: :destroy
  has_many :following_users, through: :followings, source: :following
  has_many :follower_followings, class_name: "Following", foreign_key: :following_id, dependent: :destroy
  has_many :followers, through: :follower_followings, source: :follower

  validates :email, presence: true, uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :username, presence: true, uniqueness: { case_sensitive: false },
            format: { with: /\A[a-zA-Z0-9_]+\z/, message: "can only contain letters, numbers, and underscores" },
            length: { minimum: 3, maximum: 30 }
  validates :password, length: { minimum: 8 }, if: -> { new_record? || !password.nil? }

  before_save :downcase_email

  def display_name_or_username
    display_name.presence || username
  end

  def following?(user)
    followings.exists?(following_id: user.id)
  end

  def member_of?(community)
    memberships.exists?(community: community)
  end

  def admin_of?(community)
    memberships.exists?(community: community, role: "admin")
  end

  def credible_for_scripture?
    memberships.any? { |m| %w[trusted veteran elder].include?(m.reputation_level) }
  end

  def scripture_vote_weight
    memberships.map(&:vote_weight).max || 1.0
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
