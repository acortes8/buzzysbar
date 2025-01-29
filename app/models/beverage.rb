class Beverage < ApplicationRecord
  has_one_attached :featured_image
  has_rich_text :ingredient_section
  has_rich_text :instruction_section
  has_rich_text :description
end
