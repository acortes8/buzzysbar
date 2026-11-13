# One way of making a drink: "Hurricane" and "Smuggler's Cove Hurricane" are two
# recipes for the Hurricane. Recipes belong to a logbook through their drink.
class Recipe < ApplicationRecord
  include PhotoAttachments

  belongs_to :drink
  has_one :logbook, through: :drink

  # The drink is gone when a whole logbook is deleted, and so is anyone to tell.
  after_commit -> { broadcast_refresh_later_to drink.logbook, :recipes if drink }

  has_one_attached :featured_image do |attachable|
    photo_variants(attachable)
  end
  has_rich_text :ingredient_section
  has_rich_text :instruction_section
  has_rich_text :description

  validates :title, presence: true, uniqueness: { scope: :drink_id }
  validates :ingredient_section, :instruction_section, presence: true
  validate { validate_photo(:featured_image, featured_image) if featured_image.attached? }

  # The form picks the drink by name; RecipesController finds or creates it.
  def drink_name
    drink&.name
  end
end
