require "test_helper"

class OccasionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @occasion = occasions(:tiki_night)
    login_as users(:one)
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
      post occasions_url, params: { occasion: { place_id: places(:home).id, occurred_on: "2026-10-30", person_ids: [ people(:one).id, people(:guest).id ] } }
    end

    assert_redirected_to occasion_url(Occasion.last)
    assert_equal [ people(:guest), people(:one) ], Occasion.last.people.order(:name).to_a
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
