class OccasionsController < ApplicationController
  before_action :set_occasion, only: %i[ show edit update destroy ]

  # GET /occasions or /occasions.json
  def index
    @occasions = Occasion.includes(:place, :people).order(occurred_on: :desc, created_at: :desc)
  end

  # GET /occasions/1 or /occasions/1.json
  def show
  end

  # GET /occasions/new
  def new
    @occasion = Occasion.new
  end

  # GET /occasions/1/edit
  def edit
  end

  # POST /occasions or /occasions.json
  def create
    @occasion = Occasion.new(occasion_params)

    respond_to do |format|
      if @occasion.save
        format.html { redirect_to @occasion, notice: "Occasion was successfully created." }
        format.json { render :show, status: :created, location: @occasion }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @occasion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /occasions/1 or /occasions/1.json
  def update
    respond_to do |format|
      if @occasion.update(occasion_params)
        format.html { redirect_to @occasion, notice: "Occasion was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @occasion }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @occasion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /occasions/1 or /occasions/1.json
  def destroy
    @occasion.destroy!

    respond_to do |format|
      format.html { redirect_to occasions_path, notice: "Occasion was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_occasion
      @occasion = Occasion.includes(:place, :people, { photos_attachments: :blob }, tastings: [ :drink, { ratings: :person }, { photo_attachment: :blob } ]).find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def occasion_params
      params.expect(occasion: [ :place_id, :occurred_on, :notes, person_ids: [] ])
    end
end
