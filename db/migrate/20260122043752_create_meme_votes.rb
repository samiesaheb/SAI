class CreateMemeVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :meme_votes do |t|
      t.integer :meme_id, null: false
      t.integer :user_id, null: false
      t.integer :value, null: false

      t.timestamps
    end
    add_index :meme_votes, :meme_id
    add_index :meme_votes, :user_id
    add_index :meme_votes, [:meme_id, :user_id], unique: true
  end
end
