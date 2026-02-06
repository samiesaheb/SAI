class CreateLawVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :law_votes do |t|
      t.integer :law_id, null: false
      t.integer :user_id, null: false
      t.integer :value, null: false

      t.timestamps
    end
    add_index :law_votes, :law_id
    add_index :law_votes, :user_id
    add_index :law_votes, [:law_id, :user_id], unique: true
  end
end
