class LawVote < ApplicationRecord
  belongs_to :law
  belongs_to :user

  validates :value, inclusion: { in: [-1, 1] }
  validates :user_id, uniqueness: { scope: :law_id, message: "has already voted on this law" }
  validate :user_must_be_member

  def upvote?
    value == 1
  end

  def downvote?
    value == -1
  end

  private

  def user_must_be_member
    return unless law && user
    unless user.member_of?(law.community)
      errors.add(:base, "You must be a member of the community to vote")
    end
  end
end
