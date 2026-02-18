class Activity < ApplicationRecord
  ACTIONS = %w[
    post_created
    meme_created
    comment_created
    proposal_created
    proposal_passed
    proposal_failed
    user_joined
    post_canon
    meme_canon
  ].freeze

  belongs_to :user
  belongs_to :community
  belongs_to :trackable, polymorphic: true

  validates :action, presence: true, inclusion: { in: ACTIONS }

  scope :recent, -> { order(created_at: :desc) }
  scope :for_communities, ->(community_ids) { where(community_id: community_ids) }

  def self.feed_for(user)
    community_ids = user.communities.pluck(:id)
    following_ids = user.following_users.pluck(:id)
    base = recent.includes(:user, :community, :trackable)
    community_scope = base.where(community_id: community_ids)
    if following_ids.any?
      following_scope = base.where(user_id: following_ids, action: "meme_created")
      community_scope.or(following_scope)
    else
      community_scope
    end
  end

  def description
    case action
    when "post_created"
      "#{user.username} created a new post"
    when "meme_created"
      "#{user.username} shared a new meme"
    when "comment_created"
      "#{user.username} posted a comment"
    when "proposal_created"
      "#{user.username} submitted a new proposal"
    when "proposal_passed"
      "A proposal passed in #{community.name}"
    when "proposal_failed"
      "A proposal failed in #{community.name}"
    when "user_joined"
      "#{user.username} joined the community"
    when "post_canon"
      "A post achieved canon status"
    when "meme_canon"
      "A meme achieved canon status"
    else
      "Activity in #{community.name}"
    end
  end

  def icon
    case action
    when "post_created" then "📝"
    when "meme_created" then "🖼️"
    when "comment_created" then "💬"
    when "proposal_created" then "📜"
    when "proposal_passed" then "✅"
    when "proposal_failed" then "❌"
    when "user_joined" then "👋"
    when "post_canon" then "⭐"
    when "meme_canon" then "⭐"
    else "📢"
    end
  end

  def css_class
    case action
    when "proposal_passed", "post_canon", "meme_canon"
      "activity-success"
    when "proposal_failed"
      "activity-danger"
    when "user_joined"
      "activity-info"
    else
      "activity-default"
    end
  end
end
