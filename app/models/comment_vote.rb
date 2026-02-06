class CommentVote < ApplicationRecord
  belongs_to :comment
  belongs_to :user

  validates :value, inclusion: { in: [-1, 1] }
  validates :user_id, uniqueness: { scope: :comment_id, message: "has already voted on this comment" }
  validate :user_must_be_member

  private

  def user_must_be_member
    return unless comment && user
    unless user.member_of?(comment.community)
      errors.add(:base, "You must be a member of the community to vote")
    end
  end
end
