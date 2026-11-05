class Occasions::PhotosController < ApplicationController
  before_action :prevent_in_demo, only: %i[ create update ]
  before_action :set_occasion

  # POST /occasions/1/photos
  def create
    photos = params.fetch(:photos, []).compact_blank.map { |image| @occasion.photos.new(image: image) }

    if photos.empty?
      redirect_to @occasion, alert: "Choose at least one photo.", status: :see_other
    elsif photos.all?(&:valid?)
      Photo.transaction { photos.each(&:save!) }
      redirect_to @occasion, notice: "#{helpers.pluralize(photos.size, "photo")} added.", status: :see_other
    else
      redirect_to @occasion, alert: photos.flat_map { |photo| photo.errors.full_messages }.uniq.to_sentence, status: :see_other
    end
  end

  # PATCH /occasions/1/photos/1
  def update
    photo = @occasion.photos.find(params.expect(:id))

    if photo.update(params.expect(photo: [ :published ]))
      redirect_to @occasion, notice: photo.published? ? "Photo published." : "Photo unpublished.", status: :see_other
    else
      redirect_to @occasion, alert: photo.errors.full_messages.to_sentence, status: :see_other
    end
  end

  # DELETE /occasions/1/photos/1
  def destroy
    @occasion.photos.find(params.expect(:id)).destroy
    redirect_to @occasion, notice: "Photo removed.", status: :see_other
  end

  private
    def set_occasion
      @occasion = Current.logbook.occasions.find(params.expect(:occasion_id))
    end
end
