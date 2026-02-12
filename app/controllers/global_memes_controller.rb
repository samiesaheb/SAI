class GlobalMemesController < ApplicationController
  before_action :require_login
  before_action :load_sidebar_communities

  def index
    @category = params[:category]
    @memes = Meme.approved.or(Meme.canon)
    @memes = @memes.by_category(@category) if @category.present?
    @memes = @memes.by_score.includes(:community, :author, meme_votes: { user: :memberships }, image_attachment: :blob)
  end

  private

  def load_sidebar_communities
    @sidebar_communities = Community.includes(:memberships).order(:name)
  end
end
