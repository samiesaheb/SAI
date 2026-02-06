class Comment < ApplicationRecord
  include Trackable
  track_creation :comment_created

  MAX_DEPTH = 3

  belongs_to :community
  belongs_to :author, class_name: "User"
  belongs_to :commentable, polymorphic: true
  belongs_to :parent, class_name: "Comment", optional: true
  has_many :replies, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy
  has_many :comment_votes, dependent: :destroy

  validates :body, presence: true, length: { maximum: 2000 }
  validate :user_must_be_member
  validate :depth_limit

  def score
    comment_votes.to_a.sum do |vote|
      weight = vote.user&.memberships&.find { |m| m.community_id == community_id }&.vote_weight || 1.0
      vote.value * weight
    end.round(1)
  end

  def user_vote(user)
    return nil unless user
    comment_votes.to_a.find { |v| v.user_id == user.id }
  end

  def depth
    d = 0
    node = self
    while node.parent_id.present?
      d += 1
      node = node.parent
    end
    d
  end

  private

  def user_must_be_member
    return unless community && author
    unless author.member_of?(community)
      errors.add(:base, "You must be a member of the community to comment")
    end
  end

  def depth_limit
    return unless parent_id.present?
    if depth >= MAX_DEPTH
      errors.add(:base, "Comments can only be nested #{MAX_DEPTH} levels deep")
    end
  end
end
