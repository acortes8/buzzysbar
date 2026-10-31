require "test_helper"

class TastingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @occasion = occasions(:tiki_night)
    @occasion.people << people(:guest)
    @tasting = tastings(:mai_tai_at_tiki_night)
    login_as users(:one)
  end

  test "should get new with a rating row for everyone who came" do
    get new_occasion_tasting_url(@occasion)
    assert_response :success
    assert_select "select[aria-label=?]", "Guest's score"
    assert_select "select[aria-label=?]", "One's score"
  end

  test "should create tasting with ratings, skipping people left blank" do
    assert_difference([ "Tasting.count", "Rating.count" ], 1) do
      post occasion_tastings_url(@occasion), params: { tasting: {
        drink_id: drinks(:saturn).id,
        ratings_attributes: {
          "0" => { person_id: people(:guest).id, score: "3.5", notes: "Too sweet" },
          "1" => { person_id: people(:one).id, score: "" }
        }
      } }
    end

    assert_redirected_to occasion_url(@occasion)
    assert_equal [ people(:guest) ], Tasting.last.ratings.map(&:person)
  end

  test "should not create tasting without a drink" do
    assert_no_difference("Tasting.count") do
      post occasion_tastings_url(@occasion), params: { tasting: { drink_id: "" } }
    end

    assert_response :unprocessable_entity
  end

  test "should not accept a rating from someone who wasn't there" do
    stranger = Person.create!(name: "Stranger")

    assert_no_difference("Tasting.count") do
      post occasion_tastings_url(@occasion), params: { tasting: {
        drink_id: drinks(:saturn).id,
        ratings_attributes: { "0" => { person_id: stranger.id, score: "4" } }
      } }
    end

    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_occasion_tasting_url(@occasion, @tasting)
    assert_response :success
  end

  test "should update tasting and remove a rating" do
    rating = ratings(:one_on_mai_tai)

    patch occasion_tasting_url(@occasion, @tasting), params: { tasting: {
      notes: "Updated",
      ratings_attributes: { "0" => { id: rating.id, _destroy: "1" } }
    } }

    assert_redirected_to occasion_url(@occasion)
    assert_equal "Updated", @tasting.reload.notes
    assert_empty @tasting.ratings
  end

  test "should destroy tasting and its ratings" do
    assert_difference([ "Tasting.count", "Rating.count" ], -1) do
      delete occasion_tasting_url(@occasion, @tasting)
    end

    assert_redirected_to occasion_url(@occasion)
  end

  test "occasion page lists its drinks and ratings" do
    get occasion_url(@occasion)
    assert_select "h3", text: "Mai Tai"
    assert_match "Average 4.5 / 5", response.body
  end

  test "drink page lists every time we've had it" do
    get drink_url(drinks(:mai_tai))
    assert_select "h3", text: @occasion.title
  end
end
