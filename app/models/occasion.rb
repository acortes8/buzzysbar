class Occasion < ApplicationRecord
  include PhotoAttachments

  belongs_to :place
  has_many :attendances, dependent: :destroy
  # dependent: :destroy makes unchecking someone destroy their attendance with
  # callbacks (deleting their ratings) instead of a bare SQL delete.
  has_many :people, through: :attendances, dependent: :destroy
  has_many :tastings, dependent: :destroy
  has_many_attached :photos do |attachable|
    photo_variants(attachable)
  end

  attribute :occurred_on, default: -> { Date.current }

  validates :occurred_on, presence: true
  validate { photos.each { |photo| validate_photo(:photos, photo) } }

  def title
    "#{place.name}, #{occurred_on.to_fs(:long_ordinal)}"
  end
end
