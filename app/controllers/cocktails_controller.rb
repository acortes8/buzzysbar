# Public pages for recipes someone chose to publish, which are never from
# books. Like the rankings, they use their own views: the recipe itself and
# where it's from, nothing from the logbook.
class CocktailsController < ApplicationController
  allow_unauthenticated_access

  def index
    @recipes = Recipe.published.includes(:drink, featured_image_attachment: :blob).order(:title)
  end

  def show
    @recipe = Recipe.published.includes(:drink).find(params.expect(:id))
  end
end
