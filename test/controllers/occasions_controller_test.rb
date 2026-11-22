require "test_helper"

class OccasionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @occasion = occasions(:tiki_night)
    login_as users(:one)
  end

  test "home page is the occasions list" do
    get root_url
    assert_response :success
    assert_select "h1", "Occasions"
  end

  test "should get index" do
    get occasions_url
    assert_response :success
  end

  test "should get new" do
    get new_occasion_url
    assert_response :success
  end

  test "should create occasion" do
    assert_difference("Occasion.count") do
      post occasions_url, params: { occasion: { place_name: places(:home).name.upcase, occurred_on: "2026-10-30", person_ids: [ people(:one).id, people(:guest).id ] } }
    end

    assert_redirected_to occasion_url(Occasion.last)
    assert_equal places(:home), Occasion.last.place
    assert_equal [ people(:guest), people(:one) ], Occasion.last.people.order(:name).to_a
  end

  test "should create occasion at a new place" do
    assert_difference [ "Occasion.count", "Place.count" ] do
      post occasions_url, params: { occasion: { place_name: "  Grandma's   house ", place_kind: "home", occurred_on: "2026-10-30" } }
    end

    place = Occasion.last.place
    assert_equal [ "Grandma's house", "home", logbooks(:family) ], [ place.name, place.kind, place.logbook ]
  end

  test "a new place is a bar unless chosen otherwise" do
    post occasions_url, params: { occasion: { place_name: "Lava Room", occurred_on: "2026-10-30" } }
    assert Occasion.last.place.bar?
  end

  test "the kind doesn't change an existing place" do
    post occasions_url, params: { occasion: { place_name: places(:home).name, place_kind: "bar", occurred_on: "2026-10-30" } }
    assert places(:home).reload.home?
  end

  test "should not create occasion without a place" do
    assert_no_difference [ "Occasion.count", "Place.count" ] do
      post occasions_url, params: { occasion: { place_name: " ", occurred_on: "2026-10-30" } }
    end
    assert_response :unprocessable_entity
  end

  test "should not add a place when the occasion is invalid" do
    assert_no_difference "Place.count" do
      post occasions_url, params: { occasion: { place_name: "Lava Room", occurred_on: "" } }
    end
    assert_response :unprocessable_entity
  end

  test "should show occasion" do
    get occasion_url(@occasion)
    assert_response :success
  end

  test "should get edit" do
    get edit_occasion_url(@occasion)
    assert_response :success
  end

  test "should update occasion" do
    patch occasion_url(@occasion), params: { occasion: { notes: "Updated", person_ids: [ people(:guest).id ] } }
    assert_redirected_to occasion_url(@occasion)
    assert_equal [ people(:guest) ], @occasion.reload.people.to_a
  end

  test "should destroy occasion" do
    assert_difference("Occasion.count", -1) do
      delete occasion_url(@occasion)
    end

    assert_redirected_to occasions_url
  end
end
