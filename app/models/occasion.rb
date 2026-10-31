class Occasion < ApplicationRecord
  belongs_to :place
  has_many :attendances, dependent: :destroy
  # dependent: :destroy makes unchecking someone destroy their attendance with
  # callbacks (deleting their ratings) instead of a bare SQL delete.
  has_many :people, through: :attendances, dependent: :destroy
  has_many :tastings, dependent: :destroy

  attribute :occurred_on, default: -> { Date.current }

  validates :occurred_on, presence: true

  def title
    "#{place.name}, #{occurred_on.to_fs(:long_ordinal)}"
  end
end
