require "test_helper"

# A signed-in user only ever sees or changes records in their own logbook.
# Another logbook's records are "not found", as if they didn't exist.
class LogbookIsolationTest < ActionDispatch::IntegrationTest
  setup do
    login_as users(:one)
  end

  test "lists only this logbook's records" do
    get occasions_url
    assert_select "a[href=?]", occasion_path(occasions(:tiki_night))
    assert_select "a[href=?]", occasion_path(occasions(:neighbors_night)), count: 0

    get drinks_url
    assert_select "a[href=?]", drink_path(drinks(:mai_tai))
    assert_select "a[href=?]", drink_path(drinks(:neighbors_mai_tai)), count: 0

    get places_url
    assert_no_match places(:neighbors_bar).name, response.body

    get people_url
    assert_no_match people(:neighbor).name, response.body

    get users_url
    assert_no_match users(:neighbor).email_address, response.body
  end

  test "can't open another logbook's records" do
    [
      occasion_url(occasions(:neighbors_night)),
      edit_occasion_url(occasions(:neighbors_night)),
      drink_url(drinks(:neighbors_mai_tai)),
      place_url(places(:neighbors_bar)),
      person_url(people(:neighbor)),
      user_url(users(:neighbor)),
      new_log_url(occasion_id: occasions(:neighbors_night).id)
    ].each do |url|
      get url
      assert_response :not_found, url
    end
  end

  test "can't change or delete another logbook's records" do
    patch place_url(places(:neighbors_bar)), params: { place: { name: "Renamed" } }
    assert_response :not_found
    assert_equal "The Neighborhood Lounge", places(:neighbors_bar).reload.name

    assert_no_difference("Occasion.count") do
      delete occasion_url(occasions(:neighbors_night))
    end
    assert_response :not_found

    assert_no_difference("User.count") do
      delete user_url(users(:neighbor))
    end
    assert_response :not_found
  end

  test "can't add photos to another logbook's occasion" do
    post occasion_photos_url(occasions(:neighbors_night)), params: { photos: [ fixture_file_upload("mai_tai.jpg", "image/jpeg") ] }
    assert_response :not_found
    assert_not occasions(:neighbors_night).photos.exists?
  end

  test "can't link another logbook's records by id" do
    assert_no_difference("Occasion.count") do
      post occasions_url, params: { occasion: { place_id: places(:neighbors_bar).id, occurred_on: "2026-10-30" } }
    end
    assert_response :unprocessable_entity

    patch occasion_url(occasions(:tiki_night)), params: { occasion: { person_ids: [ people(:neighbor).id ] } }
    assert_response :unprocessable_entity
    assert_not_includes occasions(:tiki_night).reload.people, people(:neighbor)

    tasting = tastings(:mai_tai_at_tiki_night)
    patch occasion_tasting_url(occasions(:tiki_night), tasting), params: { tasting: { drink_id: drinks(:neighbors_mai_tai).id } }
    assert_response :unprocessable_entity
    assert_equal drinks(:mai_tai), tasting.reload.drink

    patch person_url(people(:guest)), params: { person: { user_id: users(:neighbor).id } }
    assert_response :unprocessable_entity
    assert_nil people(:guest).reload.user
  end

  test "new records go into this logbook" do
    post places_url, params: { place: { name: "Lost Lake", kind: "bar" } }
    assert_equal logbooks(:family), Place.find_by!(name: "Lost Lake").logbook

    post log_url, params: { drink_log: { place_name: "The Neighborhood Lounge", drink_name: "Zombie" } }
    tasting = Tasting.joins(:drink).find_by!(drinks: { name: "Zombie" })
    assert_equal logbooks(:family), tasting.occasion.logbook
    assert_not_equal places(:neighbors_bar), tasting.occasion.place
  end

  test "the log form only suggests this logbook's names" do
    get new_log_url
    assert_select "option[value=?]", places(:bar).name
    assert_select "option[value=?]", places(:neighbors_bar).name, count: 0
    assert_select "input[type=checkbox][value=?]", people(:neighbor).id.to_s, count: 0
  end

  test "can't see or change another logbook's recipes" do
    get recipe_url(recipes(:pearl_diver))
    assert_response :not_found

    patch recipe_url(recipes(:pearl_diver)), params: { recipe: { title: "Mine now" } }
    assert_response :not_found

    delete recipe_url(recipes(:pearl_diver))
    assert_response :not_found
  end

  test "a recipe's drink name only finds drinks in this logbook" do
    post recipes_url, params: { recipe: { title: "Pearl Diver", drink_name: "Mai Tai", ingredient_section: "Rum", instruction_section: "Shake" } }
    assert_equal drinks(:mai_tai), Recipe.last.drink
  end

  test "can't see or change another logbook's books" do
    get book_url(books(:neighbors_book))
    assert_response :not_found

    patch book_url(books(:neighbors_book)), params: { book: { title: "Mine now" } }
    assert_response :not_found
  end

  test "a tasting can't use another logbook's recipe" do
    tasting = tastings(:mai_tai_at_tiki_night)
    patch occasion_tasting_url(tasting.occasion, tasting), params: { tasting: { recipe_id: recipes(:pearl_diver).id } }
    assert_response :unprocessable_entity
    assert_equal recipes(:mai_tai), tasting.reload.recipe
  end

  test "a riff can't be based on another logbook's recipe" do
    assert_no_difference("Recipe.count") do
      post recipes_url, params: { recipe: { title: "Pearl Diver", drink_name: "Mai Tai", based_on_id: recipes(:pearl_diver).id,
        ingredient_section: "Rum", instruction_section: "Shake" } }
    end
    assert_response :unprocessable_entity

    get new_recipe_url(based_on_id: recipes(:pearl_diver))
    assert_select "option[selected][value=?]", recipes(:pearl_diver).id.to_s, count: 0
  end

  test "a recipe's book title only finds books in this logbook" do
    post recipes_url, params: { recipe: {
      title: "Zombie", drink_name: "Zombie", source: "book", book_title: "Beachbum Berry Remixed", ingredient_section: "Rums", instruction_section: "Shake"
    } }
    assert_equal logbooks(:family), Recipe.last.book.logbook
  end
end
