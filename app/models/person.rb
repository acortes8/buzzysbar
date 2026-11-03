class Person < ApplicationRecord
  belongs_to :logbook
  belongs_to :user, optional: true
  has_many :attendances, dependent: :restrict_with_error
  has_many :occasions, through: :attendances
  has_many :ratings, dependent: :restrict_with_error

  validates :name, presence: true
  validates :user_id, uniqueness: true, allow_nil: true
  validates :user, same_logbook: true
end
