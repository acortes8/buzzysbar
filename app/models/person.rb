class Person < ApplicationRecord
  belongs_to :user, optional: true

  validates :name, presence: true
  validates :user_id, uniqueness: true, allow_nil: true
end
