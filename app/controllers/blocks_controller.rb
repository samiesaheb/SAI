class BlocksController < ApplicationController
  def index
    @current_block = Block.current
    @recent_blocks = Block.by_height.limit(20)
  end

  def show
    @block = Block.find_by!(height: params[:id])
  end
end
