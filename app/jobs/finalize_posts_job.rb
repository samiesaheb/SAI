class FinalizePostsJob < ApplicationJob
  queue_as :default

  def perform
    current_block = BitcoinBlockService.current_block
    current_height = current_block[:height]

    Post.where("locked_until_block IS NOT NULL AND locked_until_block <= ? AND finalized_at IS NULL", current_height).find_each do |post|
      post.update!(finalized_at: Time.current)
      Rails.logger.info "Finalized post ##{post.id}: #{post.title}"
    end
  end
end
