class Scripture < ApplicationRecord
  belongs_to :updated_by, class_name: "User", optional: true
  has_many :amendments, class_name: "ScriptureAmendment", dependent: :destroy

  def self.canonical
    first_or_create!(content: "", version: 1)
  end
end
