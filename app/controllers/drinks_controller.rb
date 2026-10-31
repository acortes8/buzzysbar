class DrinksController < ApplicationController
  before_action :set_drink, only: %i[ show edit update destroy ]

  # GET /drinks or /drinks.json
  def index
    @drinks = Drink.order(:name)
  end

  # GET /drinks/1 or /drinks/1.json
  def show
  end

  # GET /drinks/new
  def new
    @drink = Drink.new
  end

  # GET /drinks/1/edit
  def edit
  end

  # POST /drinks or /drinks.json
  def create
    @drink = Drink.new(drink_params)

    respond_to do |format|
      if @drink.save
        format.html { redirect_to @drink, notice: "Drink was successfully created." }
        format.json { render :show, status: :created, location: @drink }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @drink.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /drinks/1 or /drinks/1.json
  def update
    respond_to do |format|
      if @drink.update(drink_params)
        format.html { redirect_to @drink, notice: "Drink was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @drink }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @drink.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /drinks/1 or /drinks/1.json
  def destroy
    respond_to do |format|
      if @drink.destroy
        format.html { redirect_to drinks_path, notice: "Drink was successfully destroyed.", status: :see_other }
        format.json { head :no_content }
      else
        format.html { redirect_to @drink, alert: @drink.errors.full_messages.to_sentence, status: :see_other }
        format.json { render json: @drink.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_drink
      @drink = Drink.includes(tastings: [ { occasion: :place }, { ratings: :person }, { photo_attachment: :blob } ]).find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def drink_params
      params.expect(drink: [ :name, :description ])
    end
end
