class Beverage < ApplicationRecord
  include PhotoAttachments

  after_commit -> { broadcast_refresh_later_to "beverages" }

  has_one_attached :featured_image do |attachable|
    photo_variants(attachable)
  end
  has_rich_text :ingredient_section
  has_rich_text :instruction_section
  has_rich_text :description

  validates :title, presence: true, uniqueness: true
  validates :featured_image, :ingredient_section, :instruction_section, :description, presence: true
  validate { validate_photo(:featured_image, featured_image) if featured_image.attached? }
end
