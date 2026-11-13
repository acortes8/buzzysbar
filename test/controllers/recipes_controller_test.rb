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

  test "old beverage links redirect" do
    get "/beverages"
    assert_redirected_to "/recipes"
    assert_response :moved_permanently

    get "/beverages/#{@recipe.id}"
    assert_redirected_to "/recipes/#{@recipe.id}"
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
    patch recipe_url(@recipe), params: { recipe: { drink_name: "Saturn" } }
    assert_equal drinks(:saturn), @recipe.reload.drink
  end

  test "should destroy recipe" do
    assert_difference("Recipe.count", -1) do
      delete recipe_url(@recipe)
    end

    assert_redirected_to recipes_url
  end
end
