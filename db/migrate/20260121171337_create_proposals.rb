class CreateProposals < ActiveRecord::Migration[8.0]
  def change
    create_table :proposals do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.integer :community_id, null: false
      t.integer :author_id, null: false
      t.string :status, default: "voting"
      t.datetime :voting_ends_at, null: false

      t.timestamps
    end
    add_index :proposals, :community_id
    add_index :proposals, :author_id
    add_index :proposals, :status
  end
end
