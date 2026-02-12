class AddUniqueIndexToCommunitiesName < ActiveRecord::Migration[8.0]
  def up
    # Remove duplicate communities (keep the oldest one with the most content)
    duplicates = execute("SELECT LOWER(name) as lname FROM communities GROUP BY LOWER(name) HAVING COUNT(*) > 1")
    duplicates.each do |row|
      lname = row["lname"]
      ids = execute("SELECT id FROM communities WHERE LOWER(name) = '#{lname}' ORDER BY id ASC").map { |r| r["id"] }
      # Keep the first (oldest), delete the rest
      ids_to_delete = ids[1..]
      ids_to_delete.each do |id|
        execute("DELETE FROM memberships WHERE community_id = #{id}")
        execute("DELETE FROM communities WHERE id = #{id}")
      end
    end

    add_index :communities, "LOWER(name)", unique: true, name: "index_communities_on_lower_name"
  end

  def down
    remove_index :communities, name: "index_communities_on_lower_name"
  end
end
