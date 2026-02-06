class CreateMemes < ActiveRecord::Migration[8.0]
  def change
    create_table :memes do |t|
      t.integer :community_id, null: false
      t.integer :author_id, null: false
      t.string :title, null: false
      t.string :category, null: false
      t.string :status, default: "pending"
      t.integer :locked_until_block
      t.datetime :canon_at

      t.timestamps
    end
    add_index :memes, :community_id
    add_index :memes, :author_id
    add_index :memes, :category
    add_index :memes, :status
  end
end
