require "application_system_test_case"

class LoggingTest < ApplicationSystemTestCase
  setup do
    sign_in_as users(:one)
  end

  test "logging a drink at a new bar with only its name" do
    click_on "Log a drink"
    fill_in "Drink", with: "Zombie"
    fill_in "Where", with: "Lost Lake"
    press "Log it"

    assert_text "Zombie logged at Lost Lake."
    assert_selector "h3", text: "Zombie"
  end

  test "logging another drink at the same occasion, then rating it" do
    visit occasion_url(occasions(:tiki_night))
    click_on "Log another drink"
    fill_in "Drink", with: "Saturn"
    press "Log it"

    assert_text "Saturn logged at The Tiki Hut."
    assert_selector "h3", text: "Saturn"
    assert_selector "h3", text: "Mai Tai"

    within "##{dom_id(Tasting.find_by!(drink: drinks(:saturn)))}" do
      click_on "Rate or edit"
    end
    find("select[aria-label=\"One's score\"]").select("4.5")
    press "Update Tasting"

    assert_text "Saturn was updated."
    assert_text "Average 4.5 / 5"
  end
end
