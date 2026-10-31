require "test_helper"

class LogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    login_as users(:one)
  end

  test "should get new with the signed-in person checked" do
    get new_log_url
    assert_response :success
    assert_select "input[type=checkbox][value=?][checked]", people(:one).id.to_s
    assert_select "input[type=checkbox][value=?]:not([checked])", people(:guest).id.to_s
  end

  test "should prefill from an occasion" do
    get new_log_url(occasion_id: occasions(:tiki_night).id)
    assert_select "input[name=?][value=?]", "drink_log[place_name]", "The Tiki Hut"
  end

  test "should log a drink and go to its occasion" do
    post log_url, params: { drink_log: { place_name: "Lost Lake", drink_name: "Zombie", occurred_on: "2026-10-30", person_ids: [ people(:one).id ] } }

    occasion = Occasion.find_by!(place: Place.find_by!(name: "Lost Lake"))
    assert_redirected_to occasion_url(occasion)
    assert_equal "Zombie logged at Lost Lake.", flash[:notice]
  end

  test "should show errors when the drink is missing" do
    assert_no_difference("Tasting.count") do
      post log_url, params: { drink_log: { place_name: "Lost Lake", drink_name: "" } }
    end

    assert_response :unprocessable_entity
    assert_select "#error_explanation", /Drink name can't be blank/
  end

  test "requires login" do
    delete session_url
    get new_log_url
    assert_redirected_to new_session_url
  end
end
