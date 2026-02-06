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

  def member_of?(community)
    memberships.exists?(community: community)
  end

  def admin_of?(community)
    memberships.exists?(community: community, role: "admin")
  end

  private

  def downcase_email
    self.email = email.downcase
  end
end
