class Occasion < ApplicationRecord
  belongs_to :place
  has_many :attendances, dependent: :destroy
  has_many :people, through: :attendances

  attribute :occurred_on, default: -> { Date.current }

  validates :occurred_on, presence: true

  def title
    "#{place.name}, #{occurred_on.to_fs(:long_ordinal)}"
  end
end
