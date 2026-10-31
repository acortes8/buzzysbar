class Person < ApplicationRecord
  belongs_to :user, optional: true
  has_many :attendances, dependent: :restrict_with_error
  has_many :occasions, through: :attendances

  validates :name, presence: true
  validates :user_id, uniqueness: true, allow_nil: true
end
