# Owns a group's people, places, drinks and occasions. The family and the demo
# each have one, so neither can see the other's records.
class Logbook < ApplicationRecord
  # Occasions come first so they're destroyed first: people, places and drinks
  # with history can't be deleted.
  has_many :occasions, dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :places, dependent: :destroy
  has_many :drinks, dependent: :destroy
  has_many :users, dependent: :destroy

  validates :name, presence: true
end
