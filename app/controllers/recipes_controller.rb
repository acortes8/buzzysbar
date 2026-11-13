class RecipesController < ApplicationController
  before_action :set_recipe, only: %i[ show edit update destroy ]

  # GET /recipes or /recipes.json
  def index
    @recipes = Current.logbook.recipes.includes(:drink, featured_image_attachment: :blob).order(:title)
  end

  # GET /recipes/1 or /recipes/1.json
  def show
  end

  # GET /recipes/new
  def new
    @recipe = Recipe.new(drink: Current.logbook.drinks.find_by(id: params[:drink_id]))
  end

  # GET /recipes/1/edit
  def edit
  end

  # POST /recipes or /recipes.json
  def create
    @recipe = Recipe.new(recipe_params)

    respond_to do |format|
      if @recipe.save
        format.html { redirect_to @recipe, notice: "Recipe was successfully created." }
        format.json { render :show, status: :created, location: @recipe }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recipes/1 or /recipes/1.json
  def update
    respond_to do |format|
      if @recipe.update(recipe_params)
        format.html { redirect_to @recipe, notice: "Recipe was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @recipe }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipes/1 or /recipes/1.json
  def destroy
    @recipe.destroy!

    respond_to do |format|
      format.html { redirect_to recipes_path, status: :see_other, notice: "Recipe was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      @recipe = Current.logbook.recipes.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through. The drink is found or
    # created by name in the current logbook, so an id can't reach another
    # logbook's drink. Demo visitors can't upload photos.
    def recipe_params
      permitted = params.expect(recipe: [ :title, :drink_name, :featured_image, :ingredient_section, :instruction_section, :description ])
      permitted = permitted.except(:featured_image) if demo?
      if permitted.key?(:drink_name)
        drink_name = permitted.delete(:drink_name)
        permitted[:drink] = (Current.logbook.drinks.find_or_initialize_by_name(drink_name) if drink_name.present?)
      end
      permitted
    end
end
