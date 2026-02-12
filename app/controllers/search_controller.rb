class SearchController < ApplicationController
  def index
    @query = params[:q].to_s.strip
    @type = params[:type].to_s.presence || "all"

    if @query.present?
      @communities = search_communities if %w[all communities].include?(@type)
      @proposals = search_proposals if %w[all proposals].include?(@type)
      @posts = search_posts if %w[all posts].include?(@type)
      @memes = search_memes if %w[all memes].include?(@type)
    end

    @communities ||= Community.none
    @proposals ||= Proposal.none
    @posts ||= Post.none
    @memes ||= Meme.none

    @total_count = @communities.size + @proposals.size + @posts.size + @memes.size
  end

  private

  def search_communities
    Community.where("name LIKE ? OR description LIKE ? OR category LIKE ?",
                    "%#{@query}%", "%#{@query}%", "%#{@query}%")
            .order(created_at: :desc)
            .limit(20)
  end

  def search_proposals
    Proposal.where("title LIKE ? OR body LIKE ?", "%#{@query}%", "%#{@query}%")
            .includes(:community, :author, :votes, :memes)
            .order(created_at: :desc)
            .limit(30)
  end

  def search_posts
    Post.where("title LIKE ? OR body LIKE ?", "%#{@query}%", "%#{@query}%")
        .where(status: %w[approved canon])
        .includes(:community, :author, post_votes: { user: :memberships })
        .order(created_at: :desc)
        .limit(30)
  end

  def search_memes
    Meme.where("title LIKE ?", "%#{@query}%")
        .where(status: %w[approved canon])
        .includes(:community, :author)
        .order(created_at: :desc)
        .limit(30)
  end
end
