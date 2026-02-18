class CreateFollowings < ActiveRecord::Migration[7.2]
  def change
    create_table :followings do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }
      t.references :following, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end
    add_index :followings, [:follower_id, :following_id], unique: true
  end
end
