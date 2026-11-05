# Public pages for drinks someone chose to publish. They use their own views,
# which show only places, months and average scores: no people, notes or photos.
class RankingsController < ApplicationController
  allow_unauthenticated_access

  def index
    @drinks = Drink.published.includes(:tastings).order(:name)
  end

  def show
    @drink = Drink.published.includes(tastings: [ { occasion: :place }, :ratings ]).find(params.expect(:id))
  end
end
