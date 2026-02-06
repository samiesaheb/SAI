class HomeController < ApplicationController
  def index
    # Load most recent posts for everyone (logged in or not)
    @recent_posts = Post.approved.or(Post.canon)
                        .includes(:community, :author, post_votes: { user: :memberships })
                        .order(created_at: :desc)
                        .limit(10)

    if logged_in?
      @my_communities = current_user.communities.includes(:memberships, :proposals, :laws)
      my_community_ids = @my_communities.map(&:id)
      @other_communities = Community.where.not(id: my_community_ids).includes(:memberships, :proposals, :laws)

      # Pre-calculate active proposal counts to avoid N+1 queries
      all_community_ids = my_community_ids + @other_communities.map(&:id)
      @active_proposal_counts = Proposal.where(community_id: all_community_ids)
                                        .where(status: "voting")
                                        .where("voting_ends_at > ?", Time.current)
                                        .group(:community_id)
                                        .count

      @recent_proposals = Proposal.active
                                  .joins(:community => :memberships)
                                  .where(memberships: { user_id: current_user.id })
                                  .includes(:community, :author)
                                  .order(created_at: :desc)
                                  .limit(10)

      @recent_activities = Activity.feed_for(current_user).limit(10)
    end
  end
end
