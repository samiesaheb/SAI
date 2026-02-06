class AddTimeLockToLaws < ActiveRecord::Migration[8.0]
  def change
    add_column :laws, :locked_until_block, :integer
  end
end
