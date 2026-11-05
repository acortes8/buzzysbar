require "test_helper"

class PlacesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @place = places(:bar)
    login_as users(:one)
  end

  test "should get index" do
    get places_url
    assert_response :success
  end

  test "should get new" do
    get new_place_url
    assert_response :success
  end

  test "should create place" do
    assert_difference("Place.count") do
      post places_url, params: { place: { kind: "bar", name: "Another Bar" } }
    end

    assert_redirected_to place_url(Place.last)
  end

  test "should show place" do
    get place_url(@place)
    assert_response :success
  end

  test "should get edit" do
    get edit_place_url(@place)
    assert_response :success
  end

  test "should update place" do
    patch place_url(@place), params: { place: { kind: @place.kind, name: @place.name } }
    assert_redirected_to place_url(@place)
  end

  test "should destroy place" do
    assert_difference("Place.count", -1) do
      delete place_url(places(:home))
    end

    assert_redirected_to places_url
  end

  test "should not destroy place with occasions" do
    assert_no_difference("Place.count") do
      delete place_url(places(:bar))
    end

    assert_redirected_to place_url(places(:bar))
    assert_equal "Can't be deleted while it has occasions", flash[:alert]
  end

  test "should publish a bar with a review" do
    place = logbooks(:family).places.create!(name: "Lava Lounge")
    patch place_url(place), params: { place: { published: "1", review: "Fire bowls!" } }
    assert place.reload.published?
    assert_equal "Fire bowls!", place.review

    get place_url(place)
    assert_select "a[href=?]", bar_path(place)
  end

  test "demo visitors can't publish places" do
    post demo_url
    place = DemoLogbook.user.logbook.places.bar.first

    get edit_place_url(place)
    assert_select "input[name=?]", "place[published]", count: 0

    patch place_url(place), params: { place: { published: "1" } }
    assert_not place.reload.published?
  end
end
