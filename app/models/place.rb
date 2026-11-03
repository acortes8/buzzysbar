class Place < ApplicationRecord
  belongs_to :logbook
  has_many :occasions, dependent: :restrict_with_error

  enum :kind, { bar: "bar", home: "home" }, validate: true

  validates :name, presence: true
end
