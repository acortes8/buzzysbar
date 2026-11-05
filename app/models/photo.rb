# A photo from an occasion: decor, the room, or a group shot. It's its own
# record, rather than a plain attachment, so it can be published on its own.
class Photo < ApplicationRecord
  include PhotoAttachments

  belongs_to :occasion
  has_one_attached :image do |attachable|
    photo_variants(attachable)
  end

  validates :image, presence: true
  validate { validate_photo(:image, image) if image.attached? }
  # Publishing is a promise that the photo shows no people. A home's photos
  # stay private, like the home itself.
  validates :published, absence: { message: "is only for photos at bars" }, if: -> { occasion&.place&.home? }

  scope :published, -> { where(published: true) }
end
