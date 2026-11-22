class Place < ApplicationRecord
  # One drink's showing at a place, for its public review.
  DrinkScore = Data.define(:drink, :average_score, :tastings_count)

  belongs_to :logbook
  has_many :occasions, dependent: :restrict_with_error
  has_many :tastings, through: :occasions

  enum :kind, { bar: "bar", home: "home" }, validate: true

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true
  # A home's name can identify someone, so only bars get public reviews.
  validates :published, absence: { message: "is only for bars" }, if: :home?

  # Places are private until someone publishes one; published bars get a
  # public review page.
  scope :published, -> { where(published: true) }

  # Finds a place by name, ignoring case and extra spaces, or builds a new one.
  # Call it on a logbook's places: logbook.places.find_or_initialize_by_name("lava room").
  def self.find_or_initialize_by_name(name)
    name = normalize_value_for(:name, name)
    where("lower(name) = ?", name.downcase).first || new(name: name)
  end

  # Each drink we've had here, best average first. A drink's average is the
  # mean of its tastings' averages, like the drink rankings.
  def drink_scores
    tastings.group_by(&:drink).map do |drink, tastings|
      scores = tastings.filter_map(&:average_score)
      DrinkScore.new(drink:, average_score: (scores.sum / scores.size if scores.any?), tastings_count: tastings.size)
    end.sort_by { |score| [ -(score.average_score || 0), score.drink.name ] }
  end
end
