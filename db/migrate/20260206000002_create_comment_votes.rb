class CreateCommentVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :comment_votes do |t|
      t.integer :comment_id, null: false
      t.integer :user_id, null: false
      t.integer :value, null: false
      t.timestamps
    end
    add_index :comment_votes, :comment_id
    add_index :comment_votes, :user_id
    add_index :comment_votes, [:comment_id, :user_id], unique: true
  end
end
