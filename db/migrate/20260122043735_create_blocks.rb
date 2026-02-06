class CreateBlocks < ActiveRecord::Migration[8.0]
  def change
    create_table :blocks do |t|
      t.integer :height, null: false
      t.datetime :timestamp, null: false
      t.string :hash_value, null: false
      t.string :previous_hash

      t.timestamps
    end
    add_index :blocks, :height, unique: true
    add_index :blocks, :hash_value, unique: true
  end
end
