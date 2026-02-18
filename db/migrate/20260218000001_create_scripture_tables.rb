class CreateScriptureTables < ActiveRecord::Migration[8.0]
  def change
    create_table :scriptures do |t|
      t.text :content, null: false, default: ""
      t.integer :version, null: false, default: 1
      t.references :updated_by, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end

    create_table :scripture_amendments do |t|
      t.references :scripture, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :rationale, null: false
      t.text :proposed_content, null: false
      t.string :status, null: false, default: "voting"
      t.datetime :voting_ends_at, null: false

      t.timestamps
    end

    create_table :scripture_amendment_votes do |t|
      t.references :scripture_amendment, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :value, null: false

      t.timestamps
    end

    add_index :scripture_amendment_votes, [:scripture_amendment_id, :user_id], unique: true, name: "index_scripture_amendment_votes_unique"
  end
end
