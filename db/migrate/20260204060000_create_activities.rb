class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.references :user, null: false, foreign_key: true
      t.references :community, null: false, foreign_key: true
      t.references :trackable, polymorphic: true, null: false
      t.string :action, null: false
      t.json :metadata, default: {}
      t.timestamps
    end

    add_index :activities, :action
    add_index :activities, :created_at
    add_index :activities, [:community_id, :created_at]
  end
end
