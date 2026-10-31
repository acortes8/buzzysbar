class Place < ApplicationRecord
  enum :kind, { bar: "bar", home: "home" }, validate: true

  validates :name, presence: true
end
