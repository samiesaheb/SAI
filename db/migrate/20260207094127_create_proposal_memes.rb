class CreateProposalMemes < ActiveRecord::Migration[8.0]
  def change
    create_table :proposal_memes do |t|
      t.references :proposal, null: false, foreign_key: true
      t.references :meme, null: false, foreign_key: true

      t.timestamps
    end

    add_index :proposal_memes, [:proposal_id, :meme_id], unique: true
  end
end
