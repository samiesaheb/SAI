class AddReputationToMemberships < ActiveRecord::Migration[8.0]
  def change
    add_column :memberships, :reputation, :integer, default: 0, null: false
    add_column :memberships, :reputation_level, :string, default: "newcomer"
    add_index :memberships, :reputation
  end
end
