class LogsController < ApplicationController
  # GET /log/new or /log/new?occasion_id=1
  def new
    @log = if params[:occasion_id]
      DrinkLog.for_occasion(Occasion.find(params[:occasion_id]))
    else
      DrinkLog.new(person_ids: [ Current.user.person&.id ].compact)
    end
  end

  # POST /log
  def create
    @log = DrinkLog.new(log_params)

    if @log.save
      tasting = @log.tasting
      redirect_to tasting.occasion, notice: "#{tasting.drink.name} logged at #{tasting.occasion.place.name}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def log_params
      params.expect(drink_log: [ :place_name, :drink_name, :occurred_on, :other_people, :notes, :photo, person_ids: [] ])
    end
end
