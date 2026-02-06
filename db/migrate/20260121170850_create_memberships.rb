class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships do |t|
      t.integer :user_id, null: false
      t.integer :community_id, null: false
      t.string :role, default: "member"
      t.datetime :joined_at

      t.timestamps
    end
    add_index :memberships, :user_id
    add_index :memberships, :community_id
    add_index :memberships, [:user_id, :community_id], unique: true
  end
end
