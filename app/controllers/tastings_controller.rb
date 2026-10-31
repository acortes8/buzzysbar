class TastingsController < ApplicationController
  before_action :set_occasion
  before_action :set_tasting, only: %i[ edit update destroy ]

  # GET /occasions/1/tastings/1/edit
  def edit
    @tasting.build_missing_ratings
  end

  # PATCH/PUT /occasions/1/tastings/1
  def update
    if @tasting.update(tasting_params)
      redirect_to @occasion, notice: "#{@tasting.drink.name} was updated.", status: :see_other
    else
      @tasting.build_missing_ratings
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /occasions/1/tastings/1
  def destroy
    @tasting.destroy!
    redirect_to @occasion, notice: "#{@tasting.drink.name} was removed.", status: :see_other
  end

  private
    def set_occasion
      @occasion = Occasion.find(params.expect(:occasion_id))
    end

    def set_tasting
      @tasting = @occasion.tastings.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def tasting_params
      params.expect(tasting: [ :drink_id, :notes, :photo, :remove_photo, ratings_attributes: [ [ :id, :person_id, :score, :notes, :_destroy ] ] ])
    end
end
