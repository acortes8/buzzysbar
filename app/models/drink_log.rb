# Logs a drink in one step, for use at the table. Finds or creates the place,
# the drink, any new people, and the occasion at that place on that date, then
# adds the tasting. Only the place and drink names are required.
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

  validates :place_name, :drink_name, :occurred_on, presence: true

  attr_reader :tasting

  # Starts a log for another drink at an existing occasion.
  def self.for_occasion(occasion)
    new(place_name: occasion.place.name, occurred_on: occasion.occurred_on, person_ids: occasion.person_ids)
  end

  def save
    return false if invalid?

    ActiveRecord::Base.transaction do
      occasion = Occasion.find_or_create_by!(place: place, occurred_on: occurred_on)
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
      Place.where("lower(name) = ?", name.downcase).first || Place.create!(name: name)
    end

    def drink
      name = Drink.normalize_value_for(:name, drink_name)
      Drink.where("lower(name) = ?", name.downcase).first || Drink.create!(name: name)
    end

    def people
      @people ||= (Person.where(id: person_ids.compact_blank).to_a + other_people_names.map do |name|
        Person.where("lower(name) = ?", name.downcase).first || Person.create!(name: name)
      end).uniq
    end

    def other_people_names
      other_people.to_s.split(",").map(&:squish).compact_blank.uniq(&:downcase)
    end
end
