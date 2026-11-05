# Public reviews of bars someone chose to publish. Like the rankings, they use
# their own views, which show only the review, visit months, average scores
# and published photos: never names or notes.
class BarsController < ApplicationController
  allow_unauthenticated_access

  def index
    @bars = Place.bar.published.includes(:occasions).order(:name)
  end

  def show
    @bar = Place.bar.published.includes({ occasions: { photos: { image_attachment: :blob } } }, tastings: [ :drink, :ratings, { photo_attachment: :blob } ]).find(params.expect(:id))
  end
end
