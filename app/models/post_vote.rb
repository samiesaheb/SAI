class PostVote < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :value, inclusion: { in: [-1, 1] }
  validates :user_id, uniqueness: { scope: :post_id, message: "has already voted on this post" }
  validate :user_must_be_member

  after_save :check_post_canon
  after_destroy :check_post_canon

  def upvote?
    value == 1
  end

  def downvote?
    value == -1
  end

  private

  def user_must_be_member
    return unless post && user
    unless user.member_of?(post.community)
      errors.add(:base, "You must be a member of the community to vote")
    end
  end

  def check_post_canon
    post.check_canon!
  end
end
