class CreateCommunities < ActiveRecord::Migration[8.0]
  def change
    create_table :communities do |t|
      t.string :name, null: false
      t.text :description
      t.string :slug, null: false
      t.integer :consensus_threshold, default: 67
      t.integer :quorum_percentage, default: 50
      t.integer :voting_period_days, default: 7
      t.integer :creator_id, null: false
      t.string :invite_token, null: false

      t.timestamps
    end
    add_index :communities, :slug, unique: true
    add_index :communities, :creator_id
    add_index :communities, :invite_token, unique: true
  end
end
