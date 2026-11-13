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
end
