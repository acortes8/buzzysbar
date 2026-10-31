require "test_helper"

class DrinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @drink = drinks(:saturn)
    login_as users(:one)
  end

  test "should get index" do
    get drinks_url
    assert_response :success
  end

  test "should get new" do
    get new_drink_url
    assert_response :success
  end

  test "should create drink" do
    assert_difference("Drink.count") do
      post drinks_url, params: { drink: { name: "Jungle Bird" } }
    end

    assert_redirected_to drink_url(Drink.last)
  end

  test "should show drink" do
    get drink_url(@drink)
    assert_response :success
  end

  test "should get edit" do
    get edit_drink_url(@drink)
    assert_response :success
  end

  test "should update drink" do
    patch drink_url(@drink), params: { drink: { description: "Updated" } }
    assert_redirected_to drink_url(@drink)
  end

  test "should destroy drink" do
    assert_difference("Drink.count", -1) do
      delete drink_url(drinks(:saturn))
    end

    assert_redirected_to drinks_url
  end

  test "should not destroy drink with tastings" do
    assert_no_difference("Drink.count") do
      delete drink_url(drinks(:mai_tai))
    end

    assert_redirected_to drink_url(drinks(:mai_tai))
    assert_equal "Can't be deleted while it has tastings", flash[:alert]
  end
end
