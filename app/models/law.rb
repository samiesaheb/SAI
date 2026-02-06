class Law < ApplicationRecord
  belongs_to :community
  belongs_to :proposal
  has_many :law_votes, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true
  validates :passed_at, presence: true
  validates :proposal_id, uniqueness: true

  scope :by_date, -> { order(passed_at: :desc) }
  scope :by_version, -> { order(version: :desc) }
  scope :by_score, -> { left_joins(:law_votes).group(:id).order(Arel.sql("COALESCE(SUM(law_votes.value), 0) DESC")) }

  def formatted_passed_at
    passed_at.strftime("%B %d, %Y at %I:%M %p")
  end

  def upvotes
    law_votes.where(value: 1).count
  end

  def downvotes
    law_votes.where(value: -1).count
  end

  def score
    law_votes.sum(:value)
  end

  def user_vote(user)
    law_votes.find_by(user: user)
  end
end
