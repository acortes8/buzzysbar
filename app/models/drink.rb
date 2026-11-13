class Drink < ApplicationRecord
  belongs_to :logbook
  has_many :tastings, dependent: :restrict_with_error
  has_many :recipes, dependent: :restrict_with_error

  normalizes :name, with: ->(name) { name.squish }

  validates :name, presence: true, uniqueness: { scope: :logbook_id, case_sensitive: false }

  # Drinks are private until someone publishes one; published drinks get a
  # public ranking page.
  scope :published, -> { where(published: true) }

  # Finds a drink by name, ignoring case and extra spaces, or builds a new one.
  # Call it on a logbook's drinks: logbook.drinks.find_or_initialize_by_name("mai tai").
  def self.find_or_initialize_by_name(name)
    name = normalize_value_for(:name, name)
    where("lower(name) = ?", name.downcase).first || new(name: name)
  end

  # Best average score first; unrated tastings go last, newest first.
  def ranked_tastings
    tastings.sort_by { |tasting| [ -(tasting.average_score || 0), -tasting.occasion.occurred_on.jd ] }
  end
end
