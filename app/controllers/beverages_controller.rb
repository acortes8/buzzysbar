class BeveragesController < ApplicationController
  before_action :set_beverage, only: %i[ show edit update destroy ]

  # GET /beverages or /beverages.json
  def index
    @beverages = Beverage.all
  end

  # GET /beverages/1 or /beverages/1.json
  def show
  end

  # GET /beverages/new
  def new
    @beverage = Beverage.new
  end

  # GET /beverages/1/edit
  def edit
  end

  # POST /beverages or /beverages.json
  def create
    @beverage = Beverage.new(beverage_params)

    respond_to do |format|
      if @beverage.save
        format.html { redirect_to @beverage, notice: "Beverage was successfully created." }
        format.json { render :show, status: :created, location: @beverage }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @beverage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /beverages/1 or /beverages/1.json
  def update
    respond_to do |format|
      if @beverage.update(beverage_params)
        format.html { redirect_to @beverage, notice: "Beverage was successfully updated." }
        format.json { render :show, status: :ok, location: @beverage }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @beverage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /beverages/1 or /beverages/1.json
  def destroy
    @beverage.destroy!

    respond_to do |format|
      format.html { redirect_to beverages_path, status: :see_other, notice: "Beverage was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_beverage
      @beverage = Beverage.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def beverage_params
      params.expect(beverage: [ :title, :featured_image ])
    end
end
