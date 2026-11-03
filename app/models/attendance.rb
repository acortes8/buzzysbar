class Attendance < ApplicationRecord
  belongs_to :occasion
  belongs_to :person

  delegate :logbook_id, to: :occasion, allow_nil: true

  validates :person_id, uniqueness: { scope: :occasion_id }
  validates :person, same_logbook: true

  # Someone who wasn't there can't have rated anything there.
  after_destroy { Rating.where(person: person, tasting: occasion.tastings).destroy_all }
end
