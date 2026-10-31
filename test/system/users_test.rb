require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  setup do
    sign_in_as users(:one)
  end

  test "visiting the index" do
    visit users_url
    assert_selector "h1", text: "Users"
  end

  test "should create user" do
    visit users_url
    click_on "New user"

    fill_in "Name", with: "Sam"
    fill_in "Email address", with: "sam@example.com"
    fill_in "Password", with: "secret"
    fill_in "Password confirmation", with: "secret"
    press "Create User"

    assert_text "User Sam was successfully created"
  end

  test "should update user" do
    visit user_url(users(:two))
    click_on "Edit this user"

    fill_in "Name", with: "Renamed"
    fill_in "Password", with: "secret"
    fill_in "Password confirmation", with: "secret"
    press "Update User"

    assert_text "User Renamed was successfully updated"
  end

  test "should destroy user" do
    visit user_url(users(:two))
    accept_confirm { click_on "Destroy this user" }

    assert_text "User was successfully destroyed"
  end
end
