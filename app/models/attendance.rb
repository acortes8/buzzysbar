class Attendance < ApplicationRecord
  belongs_to :occasion
  belongs_to :person

  validates :person_id, uniqueness: { scope: :occasion_id }

  # Someone who wasn't there can't have rated anything there.
  after_destroy { Rating.where(person: person, tasting: occasion.tastings).destroy_all }
end
