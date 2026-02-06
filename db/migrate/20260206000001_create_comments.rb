class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.integer :community_id, null: false
      t.integer :author_id, null: false
      t.string :commentable_type, null: false
      t.integer :commentable_id, null: false
      t.integer :parent_id
      t.text :body, null: false
      t.timestamps
    end
    add_index :comments, :community_id
    add_index :comments, :author_id
    add_index :comments, [:commentable_type, :commentable_id]
    add_index :comments, :parent_id
  end
end
