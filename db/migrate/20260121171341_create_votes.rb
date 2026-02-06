class CreateVotes < ActiveRecord::Migration[8.0]
  def change
    create_table :votes do |t|
      t.integer :proposal_id, null: false
      t.integer :user_id, null: false
      t.string :value, null: false

      t.timestamps
    end
    add_index :votes, :proposal_id
    add_index :votes, :user_id
    add_index :votes, [:proposal_id, :user_id], unique: true
  end
end
