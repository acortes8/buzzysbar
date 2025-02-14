class Beverage < ApplicationRecord
  has_one_attached :featured_image
  has_rich_text :ingredient_section
  has_rich_text :instruction_section
  has_rich_text :description

  validates :title, presence: true, uniqueness: true
  validates_presence_of :featured_image
  validates_presence_of :ingredient_section
  validates_presence_of :instruction_section
  validates_presence_of :description
end
