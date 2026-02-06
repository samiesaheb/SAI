class CreateLaws < ActiveRecord::Migration[8.0]
  def change
    create_table :laws do |t|
      t.integer :community_id, null: false
      t.integer :proposal_id, null: false
      t.string :title, null: false
      t.text :body, null: false
      t.integer :version, default: 1
      t.datetime :passed_at, null: false

      t.timestamps
    end
    add_index :laws, :community_id
    add_index :laws, :proposal_id, unique: true
  end
end
