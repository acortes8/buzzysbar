require "application_system_test_case"

class RecipesTest < ApplicationSystemTestCase
  setup do
    @recipe = recipes(:mai_tai)
  end

  test "should browse recipes" do
    sign_in_as users(:one)
    visit recipes_url
    assert_text @recipe.title

    visit recipe_url(@recipe)
    assert_selector "p", text: @recipe.title
  end

  test "should create recipe for a new drink" do
    sign_in_as users(:one)
    visit new_recipe_url

    enter "Title", with: "Jungle Bird"
    enter "Drink", with: "Jungle Bird"
    find("trix-editor#recipe_ingredient_section").execute_script("this.editor.insertString(arguments[0])", "Rum, Campari, pineapple, lime")
    find("trix-editor#recipe_instruction_section").execute_script("this.editor.insertString(arguments[0])", "Shake with ice")
    press "Create Recipe"

    assert_text "Recipe was successfully created"
    assert_text "A recipe for Jungle Bird"
  end

  test "should update recipe" do
    sign_in_as users(:one)
    visit recipe_url(@recipe)
    press "Edit this recipe"

    enter "Title", with: "Mai Tai (1944)"
    press "Update Recipe"

    assert_text "Recipe was successfully updated"
    assert_text "Mai Tai (1944)"
  end

  test "should destroy recipe" do
    sign_in_as users(:one)
    visit recipe_url(@recipe)
    accept_confirm_dialog("Are you sure?") { press "Destroy this recipe" }

    assert_text "Recipe was successfully destroyed"
    assert_no_selector "h1", exact_text: @recipe.title
  end

  test "shows only the source fields that apply" do
    sign_in_as users(:one)
    visit edit_recipe_url(@recipe)

    assert_no_field "Book"
    select "A book", from: "Where it's from"
    assert_field "Book"
    assert_no_field "Bartender or bar"

    select "A bartender", from: "Where it's from"
    assert_field "Bartender or bar"
    assert_no_field "Book"
  end
end
