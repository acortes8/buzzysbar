class Rating < ApplicationRecord
  SCORES = (1..5).step(0.5).map { |score| score.to_d }

  belongs_to :tasting
  belongs_to :person

  validates :score, presence: true, inclusion: { in: SCORES, message: "must be from 1 to 5 in half points", allow_nil: true }
  validates :person_id, uniqueness: { scope: :tasting_id }
  validate :person_was_at_occasion

  private
    def person_was_at_occasion
      return if person.nil? || tasting.nil?

      errors.add(:person, "wasn't at this occasion") unless tasting.occasion.people.include?(person)
    end
end
