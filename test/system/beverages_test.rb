require "application_system_test_case"

class BeveragesTest < ApplicationSystemTestCase
  setup do
    @beverage = beverages(:one)
  end

  test "visiting the index" do
    visit beverages_url
    assert_selector "h1", text: "Beverages"
  end

  test "should create beverage" do
    visit beverages_url
    click_on "New beverage"

    fill_in "Title", with: @beverage.title
    click_on "Create Beverage"

    assert_text "Beverage was successfully created"
    click_on "Back"
  end

  test "should update Beverage" do
    visit beverage_url(@beverage)
    click_on "Edit this beverage", match: :first

    fill_in "Title", with: @beverage.title
    click_on "Update Beverage"

    assert_text "Beverage was successfully updated"
    click_on "Back"
  end

  test "should destroy Beverage" do
    visit beverage_url(@beverage)
    click_on "Destroy this beverage", match: :first

    assert_text "Beverage was successfully destroyed"
  end
end
