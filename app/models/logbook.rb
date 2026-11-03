# Owns a group's people, places, drinks and occasions. The family and the demo
# each have one, so neither can see the other's records.
class Logbook < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :people, dependent: :destroy
  has_many :places, dependent: :destroy
  has_many :drinks, dependent: :destroy
  has_many :occasions, dependent: :destroy

  validates :name, presence: true
end
