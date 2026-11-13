require "test_helper"

class RecipeTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile

  test "requires a title, drink, ingredients and instructions" do
    recipe = Recipe.new
    assert recipe.invalid?
    assert recipe.errors[:title].any?
    assert_includes recipe.errors[:drink], "can't be blank"
    assert recipe.errors[:ingredient_section].any?
    assert recipe.errors[:instruction_section].any?
  end

  test "a photo and description are optional" do
    recipe = drinks(:saturn).recipes.new(title: "Saturn", ingredient_section: "Gin", instruction_section: "Blend")
    assert recipe.valid?
  end

  test "titles are unique per drink" do
    recipe = drinks(:mai_tai).recipes.new(title: recipes(:mai_tai).title)
    assert recipe.invalid?
    assert_equal [ I18n.translate("errors.messages.taken") ], recipe.errors[:title]

    assert drinks(:saturn).recipes.new(title: recipes(:mai_tai).title, ingredient_section: "Rum", instruction_section: "Shake").valid?
  end

  test "belongs to its drink's logbook" do
    assert_equal logbooks(:family), recipes(:mai_tai).logbook
    assert_equal [ recipes(:mai_tai) ], logbooks(:family).recipes.to_a
  end

  test "accepts a HEIC featured image" do
    recipe = recipes(:mai_tai)
    recipe.featured_image.attach(fixture_file_upload("drink.heic", "image/heic"))
    recipe.valid?
    assert_empty recipe.errors[:featured_image]
  end

  test "rejects a featured image that isn't an image" do
    recipe = recipes(:mai_tai)
    recipe.featured_image.attach(fixture_file_upload("notes.txt", "text/plain"))
    assert_not recipe.valid?
    assert_includes recipe.errors[:featured_image], "must be a JPEG, PNG, GIF, WebP, or HEIC image"
  end
end
