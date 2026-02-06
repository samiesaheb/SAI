class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.integer :community_id, null: false
      t.integer :author_id, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.string :category, null: false
      t.string :status, default: "pending"
      t.float :quality_score, default: 0.0
      t.string :ml_category
      t.integer :word_count, default: 0
      t.text :sources
      t.integer :locked_until_block
      t.datetime :canon_at
      t.datetime :finalized_at
      t.integer :bitcoin_block_height
      t.string :bitcoin_block_hash

      t.timestamps
    end
    add_index :posts, :community_id
    add_index :posts, :author_id
    add_index :posts, :category
    add_index :posts, :status
  end
end
