# A book we take recipes from. Its recipes are never published, since they're
# someone else's work.
class Book < ApplicationRecord
  belongs_to :logbook
  has_many :recipes, dependent: :restrict_with_error

  normalizes :title, :author, with: ->(value) { value.squish }

  validates :title, presence: true, uniqueness: { scope: :logbook_id, case_sensitive: false }

  # Finds a book by title, ignoring case and extra spaces, or builds a new one.
  # Call it on a logbook's books, like Drink.find_or_initialize_by_name.
  def self.find_or_initialize_by_title(title)
    title = normalize_value_for(:title, title)
    where("lower(title) = ?", title.downcase).first || new(title: title)
  end
end
