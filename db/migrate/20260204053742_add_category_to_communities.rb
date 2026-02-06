class AddCategoryToCommunities < ActiveRecord::Migration[8.0]
  def change
    add_column :communities, :category, :string, default: "general"
    add_index :communities, :category
  end
end
