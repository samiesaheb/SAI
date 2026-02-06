class MemeVote < ApplicationRecord
  belongs_to :meme
  belongs_to :user

  validates :value, inclusion: { in: [-1, 1] }
  validates :user_id, uniqueness: { scope: :meme_id, message: "has already voted on this meme" }
  validate :user_must_be_member

  after_save :check_meme_canon
  after_destroy :check_meme_canon

  def upvote?
    value == 1
  end

  def downvote?
    value == -1
  end

  private

  def user_must_be_member
    return unless meme && user
    unless user.member_of?(meme.community)
      errors.add(:base, "You must be a member of the community to vote")
    end
  end

  def check_meme_canon
    meme.check_canon!
  end
end
