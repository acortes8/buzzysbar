# Public reviews of bars someone chose to publish. Like the rankings, they use
# their own views, which show only the review, visit months and average
# scores: no people, notes or photos.
class BarsController < ApplicationController
  allow_unauthenticated_access

  def index
    @bars = Place.bar.published.includes(:occasions).order(:name)
  end

  def show
    @bar = Place.bar.published.includes(:occasions, tastings: [ :drink, :ratings ]).find(params.expect(:id))
  end
end
