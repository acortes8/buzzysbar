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
    press "New user"

    enter "Name", with: "Sam"
    enter "Email address", with: "sam@example.com"
    enter "Password", with: "secret"
    enter "Password confirmation", with: "secret"
    press "Create User"

    assert_text "User Sam was successfully created"
  end

  test "should update user" do
    visit user_url(users(:two))
    press "Edit this user"

    enter "Name", with: "Renamed"
    enter "Password", with: "secret"
    enter "Password confirmation", with: "secret"
    press "Update User"

    assert_text "User Renamed was successfully updated"
  end

  test "should destroy user" do
    visit user_url(users(:two))
    accept_confirm_dialog("Are you sure?") { press "Destroy this user" }

    assert_text "User was successfully destroyed"
  end
end
