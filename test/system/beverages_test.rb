require "application_system_test_case"

class BeveragesTest < ApplicationSystemTestCase
  setup do
    @beverage = beverages(:mai_tai)
  end

  test "visitors can browse recipes without signing in" do
    visit beverages_url
    assert_text @beverage.title

    visit beverage_url(@beverage)
    assert_selector "p", text: @beverage.title
    assert_no_link "Log a drink"
  end

  test "should update beverage" do
    sign_in_as users(:one)
    visit beverage_url(@beverage)
    press "Edit this beverage"

    enter "Title", with: "Mai Tai (1944)"
    press "Update Beverage"

    assert_text "Beverage was successfully updated"
    assert_text "Mai Tai (1944)"
  end

  test "should destroy beverage" do
    sign_in_as users(:one)
    visit beverage_url(@beverage)
    accept_confirm_dialog("Are you sure?") { press "Destroy this beverage" }

    assert_text "Beverage was successfully destroyed"
    assert_no_text @beverage.title
  end
end
