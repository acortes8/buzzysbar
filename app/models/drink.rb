class Drink < ApplicationRecord
  belongs_to :logbook
  has_many :tastings, dependent: :restrict_with_error

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, uniqueness: { scope: :logbook_id, case_sensitive: false }
end
