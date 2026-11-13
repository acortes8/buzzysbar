# Logs a drink in one step, for use at the table. Finds or creates the place,
# the drink, any new people, and the occasion at that place on that date, then
# adds the tasting, all within the given logbook. Only the place and drink
# names are required.
class DrinkLog
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :place_name, :string
  attribute :drink_name, :string
  attribute :occurred_on, :date, default: -> { Date.current }
  attribute :person_ids, default: -> { [] }
  attribute :other_people, :string
  attribute :notes, :string
  attribute :photo

  attr_accessor :logbook

  validates :place_name, :drink_name, :occurred_on, presence: true

  attr_reader :tasting

  # Starts a log for another drink at an existing occasion.
  def self.for_occasion(occasion)
    new(logbook: occasion.logbook, place_name: occasion.place.name, occurred_on: occasion.occurred_on, person_ids: occasion.person_ids)
  end

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      occasion = logbook.occasions.find_or_create_by!(place: place, occurred_on: occurred_on)
      (people - occasion.people).each { |person| occasion.people << person }
      @tasting = occasion.tastings.create!(drink: drink, notes: notes, photo: photo.presence)
    end
    true
  rescue ActiveRecord::RecordInvalid => invalid
    invalid.record.errors.each { |error| errors.add(:base, error.full_message) }
    false
  end

  private
    def place
      name = place_name.squish
      logbook.places.where("lower(name) = ?", name.downcase).first || logbook.places.create!(name: name)
    end

    def drink
      logbook.drinks.find_or_initialize_by_name(drink_name).tap(&:save!)
    end

    def people
      @people ||= (logbook.people.where(id: person_ids.compact_blank).to_a + other_people_names.map do |name|
        logbook.people.where("lower(name) = ?", name.downcase).first || logbook.people.create!(name: name)
      end).uniq
    end

    def other_people_names
      other_people.to_s.split(",").map(&:squish).compact_blank.uniq(&:downcase)
    end
end
