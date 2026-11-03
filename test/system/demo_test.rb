require "application_system_test_case"

class DemoTest < ApplicationSystemTestCase
  test "trying the demo from the sign-in page" do
    visit new_session_url
    press "Try the demo"

    assert_selector "#demo-banner", text: "You're in the demo"
    assert_selector "h1", text: "Occasions"
    assert_text "The Coconut Lantern"
  end
end
