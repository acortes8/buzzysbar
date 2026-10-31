class Occasions::PhotosController < ApplicationController
  before_action :set_occasion

  # POST /occasions/1/photos
  def create
    photos = params.fetch(:photos, []).compact_blank

    if photos.empty?
      redirect_to @occasion, alert: "Choose at least one photo.", status: :see_other
    elsif @occasion.photos.attach(photos)
      redirect_to @occasion, notice: "#{helpers.pluralize(photos.size, "photo")} added.", status: :see_other
    else
      redirect_to @occasion, alert: @occasion.errors.full_messages.to_sentence, status: :see_other
    end
  end

  # DELETE /occasions/1/photos/1
  def destroy
    @occasion.photos.find(params.expect(:id)).purge_later
    redirect_to @occasion, notice: "Photo removed.", status: :see_other
  end

  private
    def set_occasion
      @occasion = Occasion.find(params.expect(:occasion_id))
    end
end
