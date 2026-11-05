# Public pages for drinks someone chose to publish. They use their own views,
# which show only places, months, average scores and photos published as having
# no people in them: never names or notes.
class RankingsController < ApplicationController
  allow_unauthenticated_access

  def index
    @drinks = Drink.published.includes(:tastings).order(:name)
  end

  def show
    @drink = Drink.published.includes(tastings: [ { occasion: :place }, :ratings, { photo_attachment: :blob } ]).find(params.expect(:id))
  end
end
