require "test_helper"

class CocktailsControllerTest < ActionDispatch::IntegrationTest
  test "lists published recipes without signing in" do
    get cocktails_url
    assert_response :success
    assert_select "#cocktails a[href=?]", cocktail_path(recipes(:mai_tai))
    assert_select "#cocktails a[href=?]", cocktail_path(recipes(:mai_tai_from_book)), count: 0
  end

  test "shows a published recipe without signing in" do
    get cocktail_url(recipes(:mai_tai))
    assert_response :success
    assert_select "h1", "Mai Tai"
    assert_match "Our own recipe", response.body
    assert_match "orgeat", response.body
  end

  test "links the drink's ranking when it's published" do
    get cocktail_url(recipes(:mai_tai))
    assert_select "a[href=?]", ranking_path(drinks(:mai_tai))
  end

  test "unpublished recipes are not found" do
    recipes(:mai_tai).update!(published: false)
    get cocktail_url(recipes(:mai_tai))
    assert_response :not_found
  end

  test "recipes from books are not found even if marked published" do
    recipes(:mai_tai_from_book).update_column(:published, true)
    get cocktail_url(recipes(:mai_tai_from_book))
    assert_response :not_found
  end

  test "names a published original and published riffs" do
    riff = drinks(:mai_tai).recipes.create!(title: "Dark Mai Tai", based_on: recipes(:mai_tai), source: "ours", published: true,
      ingredient_section: "Dark rum", instruction_section: "Shake")

    get cocktail_url(riff)
    assert_select "a[href=?]", cocktail_path(recipes(:mai_tai)), text: "Mai Tai"

    get cocktail_url(recipes(:mai_tai))
    assert_select "#riffs a[href=?]", cocktail_path(riff)
  end

  test "doesn't name an original or riffs that aren't public" do
    drinks(:mai_tai).recipes.create!(title: "Uncle's Mai Tai", based_on: recipes(:mai_tai), source: "ours",
      ingredient_section: "Rum", instruction_section: "Shake")

    get cocktail_url(recipes(:mai_tai))
    assert_no_match "Smuggler's Cove Mai Tai", response.body
    assert_no_match "Uncle's Mai Tai", response.body
    assert_select "#riffs", count: 0
  end
end
