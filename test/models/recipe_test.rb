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
    assert_equal [ recipes(:mai_tai), recipes(:mai_tai_from_book) ], logbooks(:family).recipes.order(:title).to_a
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

  test "a book source needs a book from the same logbook" do
    recipe = recipes(:mai_tai)
    recipe.source = "book"
    assert_not recipe.valid?
    assert_includes recipe.errors[:book], "can't be blank"

    recipe.book = books(:neighbors_book)
    assert_not recipe.valid?
    assert_includes recipe.errors[:book], "must be in the same logbook"
  end

  test "a bartender or bar source needs a credit" do
    recipe = recipes(:mai_tai)
    recipe.published = false
    recipe.source = "bartender"
    assert_not recipe.valid?
    assert_includes recipe.errors[:credit], "can't be blank"

    recipe.credit = "  Martin   Cate "
    assert recipe.valid?
    assert_equal "Martin Cate", recipe.credit
  end

  test "the page must be a positive number" do
    recipe = recipes(:mai_tai_from_book)
    recipe.page = 0
    assert_not recipe.valid?
  end

  test "drops details that don't match the source" do
    recipe = recipes(:mai_tai_from_book)
    recipe.update!(source: "bar", credit: "Smuggler's Cove")
    assert_nil recipe.book
    assert_nil recipe.page
    assert_equal "Smuggler's Cove", recipe.credit
  end

  test "recipes from books can't be published" do
    recipe = recipes(:mai_tai_from_book)
    recipe.published = true
    assert_not recipe.valid?
    assert_includes recipe.errors[:published], "needs a source that isn't a book"
  end

  test "recipes without a source can't be published" do
    recipe = recipes(:mai_tai)
    recipe.source = nil
    assert_not recipe.valid?
    assert_includes recipe.errors[:published], "needs a source that isn't a book"
  end

  test "published never includes a recipe from a book" do
    recipes(:mai_tai_from_book).update_column(:published, true)
    assert_equal [ recipes(:mai_tai) ], Recipe.published.to_a
  end

  test "a riff is based on another recipe" do
    assert_equal recipes(:mai_tai_from_book), recipes(:mai_tai).based_on
    assert_equal [ recipes(:mai_tai) ], recipes(:mai_tai_from_book).riffs
  end

  test "can't be based on itself or one of its riffs" do
    original = recipes(:mai_tai_from_book)
    original.based_on = original
    assert original.invalid?
    assert_includes original.errors[:based_on], "can't be this recipe or one of its riffs"

    original.based_on = recipes(:mai_tai)
    assert original.invalid?
    assert_includes original.errors[:based_on], "can't be this recipe or one of its riffs"
  end

  test "can't be based on another logbook's recipe" do
    recipe = recipes(:mai_tai)
    recipe.based_on = recipes(:pearl_diver)
    assert recipe.invalid?
    assert_includes recipe.errors[:based_on], "must be in the same logbook"
  end

  test "deleting the original keeps its riffs" do
    recipes(:mai_tai_from_book).destroy!
    assert_nil recipes(:mai_tai).reload.based_on
  end
end
