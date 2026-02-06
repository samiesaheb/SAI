class CreatePostVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :post_votes do |t|
      t.integer :post_id, null: false
      t.integer :user_id, null: false
      t.integer :value, null: false

      t.timestamps
    end
    add_index :post_votes, :post_id
    add_index :post_votes, :user_id
    add_index :post_votes, [:post_id, :user_id], unique: true
  end
end
