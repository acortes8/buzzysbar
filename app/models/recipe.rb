# One way of making a drink: "Hurricane" and "Smuggler's Cove Hurricane" are two
# recipes for the Hurricane. Recipes belong to a logbook through their drink.
class Recipe < ApplicationRecord
  include PhotoAttachments

  belongs_to :drink
  belongs_to :book, optional: true
  has_one :logbook, through: :drink

  delegate :logbook_id, to: :drink, allow_nil: true

  # Where the recipe comes from; nil means it wasn't recorded. A book also has
  # a page, and a bartender or bar is named in the credit.
  enum :source, { ours: "ours", book: "book", bartender: "bartender", bar: "bar" }, prefix: true, validate: { allow_nil: true }

  # The drink is gone when a whole logbook is deleted, and so is anyone to tell.
  after_commit -> { broadcast_refresh_later_to drink.logbook, :recipes if drink }

  has_one_attached :featured_image do |attachable|
    photo_variants(attachable)
  end
  has_rich_text :ingredient_section
  has_rich_text :instruction_section
  has_rich_text :description

  normalizes :credit, with: ->(credit) { credit.squish.presence }

  before_validation :clear_unused_source_details

  validates :title, presence: true, uniqueness: { scope: :drink_id }
  validates :ingredient_section, :instruction_section, presence: true
  validates :book, presence: true, same_logbook: true, if: :source_book?
  validates :page, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :credit, presence: true, if: -> { source_bartender? || source_bar? }
  # Recipes from books are someone else's work, and one with no source might
  # be from a book, so only recipes with another known source can be public.
  validates :published, absence: { message: "needs a source that isn't a book" }, unless: :publishable?
  validate { validate_photo(:featured_image, featured_image) if featured_image.attached? }

  # Published recipes for public pages. The source check repeats the
  # validation, so a recipe from a book can't slip through.
  scope :published, -> { where(published: true).where(source: %w[ ours bartender bar ]) }

  # The form picks the drink by name; RecipesController finds or creates it.
  def drink_name
    drink&.name
  end

  # Likewise for the book, by title.
  def book_title
    book&.title
  end

  def publishable?
    source.present? && !source_book?
  end

  private
    def clear_unused_source_details
      self.book = nil unless source_book?
      self.page = nil unless source_book?
      self.credit = nil unless source_bartender? || source_bar?
    end
end
