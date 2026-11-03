class Tasting < ApplicationRecord
  include PhotoAttachments

  belongs_to :occasion
  belongs_to :drink
  has_many :ratings, dependent: :destroy
  has_one_attached :photo do |attachable|
    photo_variants(attachable)
  end

  delegate :logbook_id, to: :occasion, allow_nil: true

  attribute :remove_photo, :boolean
  # A new upload wins over "remove photo" if both are sent.
  after_save { photo.purge_later if remove_photo && photo.attached? && !attachment_changes.key?("photo") }

  validates :drink, same_logbook: true
  validate { validate_photo(:photo, photo) if photo.attached? }

  accepts_nested_attributes_for :ratings, allow_destroy: true,
    reject_if: ->(attributes) { attributes[:id].blank? && attributes[:score].blank? && attributes[:notes].blank? }

  # Adds an unsaved rating for each person at the occasion who hasn't rated
  # this tasting yet, so the form shows a row for everyone who was there.
  def build_missing_ratings
    rated = ratings.map(&:person_id)
    occasion.people.order(:name).each do |person|
      ratings.build(person: person) unless rated.include?(person.id)
    end
  end

  def average_score
    scores = ratings.map(&:score).compact
    scores.sum / scores.size if scores.any?
  end
end
