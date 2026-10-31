require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # Sets the fields directly instead of typing: in a full run, typing into
  # the sign-in form was intermittently lost, and signing in is only setup
  # for these tests.
  def sign_in_as(user)
    visit new_session_url
    find_field("email_address").execute_script("this.value = arguments[0]", user.email_address)
    find_field("password").execute_script("this.value = arguments[0]", "password")
    press "Sign in"
    assert_selector "h1", text: "Occasions"
  end

  # Chrome shows earlier names in native popups under the field being typed
  # in, and an open popup can swallow a real mouse click on the button below
  # it. After typing, submit by clicking through the DOM.
  def press(button)
    find_button(button).execute_script("this.click()")
  end
end
