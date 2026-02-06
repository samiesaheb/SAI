class MineBlockJob < ApplicationJob
  queue_as :default

  def perform
    Block.mine!
    Rails.logger.info "Mined block ##{Block.current_height}"
  end
end
