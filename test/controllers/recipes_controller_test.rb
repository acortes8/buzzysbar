require "test_helper"

class RecipesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recipe = recipes(:mai_tai)
    login_as users(:one)
  end

  test "should get index with only this logbook's recipes" do
    get recipes_url
    assert_response :success
    assert_match recipes(:mai_tai).title, response.body
    assert_no_match recipes(:pearl_diver).title, response.body
  end

  test "subscribes to this logbook's live updates" do
    get recipes_url
    assert_select "turbo-cable-stream-source", 1
  end

  test "recipes are private" do
    delete session_url

    get recipes_url
    assert_redirected_to new_session_url

    get recipe_url(@recipe)
    assert_redirected_to new_session_url
  end

  test "old beverage links redirect to the public pages" do
    get "/beverages"
    assert_redirected_to "/cocktails"
    assert_response :moved_permanently

    get "/beverages/#{@recipe.id}"
    assert_redirected_to "/cocktails/#{@recipe.id}"
  end

  test "should get new" do
    get new_recipe_url
    assert_response :success
  end

  test "new can start from a drink" do
    get new_recipe_url(drink_id: drinks(:saturn).id)
    assert_select "input[name=?][value=?]", "recipe[drink_name]", "Saturn"
  end

  test "should create recipe for an existing drink, ignoring case" do
    assert_difference("Recipe.count") do
      assert_no_difference("Drink.count") do
        post recipes_url, params: { recipe: {
          title: "Trader Vic's Mai Tai", drink_name: " mai  TAI ",
          featured_image: file_fixture_upload("mai_tai.jpg", "image/jpeg"),
          ingredient_section: "Rum, lime, curaçao, orgeat", instruction_section: "Shake"
        } }
      end
    end

    recipe = Recipe.last
    assert_redirected_to recipe_url(recipe)
    assert_equal drinks(:mai_tai), recipe.drink
  end

  test "should create recipe and a new drink" do
    assert_difference([ "Recipe.count", "Drink.count" ]) do
      post recipes_url, params: { recipe: {
        title: "Jungle Bird", drink_name: "Jungle Bird", ingredient_section: "Rum, Campari", instruction_section: "Shake"
      } }
    end

    assert_equal logbooks(:family), Recipe.last.logbook
  end

  test "should not create recipe without a drink" do
    assert_no_difference("Recipe.count") do
      post recipes_url, params: { recipe: { title: "Mystery", drink_name: "", ingredient_section: "Rum", instruction_section: "Shake" } }
    end

    assert_response :unprocessable_entity
    assert_match "Drink can&#39;t be blank", response.body
  end

  test "should not add a drink when the recipe is invalid" do
    assert_no_difference("Drink.count") do
      post recipes_url, params: { recipe: { title: "", drink_name: "Zombie", ingredient_section: "Rum", instruction_section: "Shake" } }
    end
  end

  test "should show recipe" do
    get recipe_url(@recipe)
    assert_response :success
  end

  test "should get edit" do
    get edit_recipe_url(@recipe)
    assert_response :success
  end

  test "should update recipe" do
    patch recipe_url(@recipe), params: { recipe: { title: "Mai Tai (1944)" } }
    assert_redirected_to recipe_url(@recipe)
    assert_equal drinks(:mai_tai), @recipe.reload.drink
  end

  test "should move recipe to another drink" do
    recipe = recipes(:mai_tai_from_book)
    patch recipe_url(recipe), params: { recipe: { drink_name: "Saturn" } }
    assert_equal drinks(:saturn), recipe.reload.drink
  end

  test "should not move a recipe a tasting used" do
    patch recipe_url(@recipe), params: { recipe: { drink_name: "Saturn" } }
    assert_response :unprocessable_entity
    assert_equal drinks(:mai_tai), @recipe.reload.drink
  end

  test "shows the tastings made with the recipe" do
    get recipe_url(@recipe)
    assert_select "#tastings a[href=?]", occasion_path(occasions(:tiki_night))
  end

  test "should destroy recipe" do
    assert_difference("Recipe.count", -1) do
      delete recipe_url(@recipe)
    end

    assert_redirected_to recipes_url
  end

  test "should create a recipe from a new book" do
    assert_difference("Book.count") do
      post recipes_url, params: { recipe: {
        title: "Tiki Saturn", drink_name: "Saturn", source: "book", book_title: "Tiki: Modern Tropical Cocktails", page: "88",
        ingredient_section: "Gin", instruction_section: "Blend"
      } }
    end

    recipe = Recipe.last
    assert_equal "Tiki: Modern Tropical Cocktails", recipe.book.title
    assert_equal 88, recipe.page
    assert_equal logbooks(:family), recipe.book.logbook
  end

  test "should find an existing book by title" do
    assert_no_difference("Book.count") do
      patch recipe_url(@recipe), params: { recipe: { source: "book", book_title: "smuggler's cove", published: "0" } }
    end
    assert_equal books(:smugglers_cove), @recipe.reload.book
  end

  test "shows where a recipe is from" do
    get recipe_url(recipes(:mai_tai_from_book))
    assert_select "a[href=?]", book_path(books(:smugglers_cove)), text: "Smuggler's Cove"
    assert_match "page 112", response.body
  end

  test "should publish a recipe of our own" do
    recipe = recipes(:mai_tai)
    recipe.update!(published: false)

    patch recipe_url(recipe), params: { recipe: { published: "1" } }
    assert recipe.reload.published?

    get recipe_url(recipe)
    assert_select "a[href=?]", cocktail_path(recipe)
  end

  test "should not publish a recipe from a book" do
    recipe = recipes(:mai_tai_from_book)
    patch recipe_url(recipe), params: { recipe: { published: "1" } }

    assert_response :unprocessable_entity
    assert_not recipe.reload.published?
  end

  test "new riff starts from the original and its drink" do
    get new_recipe_url(based_on_id: recipes(:mai_tai))
    assert_select "select[name=?] option[selected][value=?]", "recipe[based_on_id]", recipes(:mai_tai).id.to_s
    assert_select "input[name=?][value=?]", "recipe[drink_name]", "Mai Tai"
  end

  test "should create a riff" do
    assert_difference("recipes(:mai_tai).riffs.count") do
      post recipes_url, params: { recipe: { title: "Dark Mai Tai", drink_name: "Mai Tai", based_on_id: recipes(:mai_tai).id,
        ingredient_section: "Dark rum", instruction_section: "Shake" } }
    end
    assert_redirected_to recipe_url(Recipe.find_by!(title: "Dark Mai Tai"))
  end

  test "shows the original and the riffs" do
    get recipe_url(recipes(:mai_tai))
    assert_select "a[href=?]", recipe_path(recipes(:mai_tai_from_book)), text: "Smuggler's Cove Mai Tai"

    get recipe_url(recipes(:mai_tai_from_book))
    assert_select "#riffs a[href=?]", recipe_path(recipes(:mai_tai))
  end
end
