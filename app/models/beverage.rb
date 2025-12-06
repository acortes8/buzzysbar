class Beverage < ApplicationRecord
  after_commit -> { broadcast_refresh_later_to "beverages" }

  has_one_attached :featured_image
  has_rich_text :ingredient_section
  has_rich_text :instruction_section
  has_rich_text :description

  validates :title, presence: true, uniqueness: true
  validates :featured_image, :ingredient_section, :instruction_section, :description, presence: true

  def acceptable_image
    return unless featured_image.attached?

    acceptable_types = [ "image/gif", "image/jpeg", "image/png" ]
    unless acceptable_types.include?(featured_image.content_type)
      errors.add(:featured_image, "must be a GIF, JPEG, or PNG image")
    end
  end
end
