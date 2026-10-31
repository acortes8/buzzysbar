class Attendance < ApplicationRecord
  belongs_to :occasion
  belongs_to :person

  validates :person_id, uniqueness: { scope: :occasion_id }
end
