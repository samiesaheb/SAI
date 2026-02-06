module ActivitiesHelper
  def trackable_path(activity)
    case activity.trackable_type
    when "Post"
      community_post_path(activity.community, activity.trackable)
    when "Meme"
      community_meme_path(activity.community, activity.trackable)
    when "Proposal"
      community_proposal_path(activity.community, activity.trackable)
    when "Membership"
      community_path(activity.community)
    when "Comment"
      commentable = activity.trackable&.commentable
      if commentable.is_a?(Post)
        community_post_path(activity.community, commentable)
      elsif commentable.is_a?(Meme)
        community_meme_path(activity.community, commentable)
      else
        community_path(activity.community)
      end
    else
      community_path(activity.community)
    end
  rescue
    community_path(activity.community)
  end
end
