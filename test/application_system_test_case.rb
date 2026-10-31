require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # In this suite, headless Chrome intermittently dropped or delayed native
  # input from the driver, locally and in CI: typing could land after the
  # next click, and clicks could be swallowed by its suggestion popups. These
  # helpers act through the DOM instead, so each step finishes before the
  # next. They still go through the real fields, links, buttons, Turbo, and
  # confirm dialogs.
  def enter(locator, with:)
    find_field(locator).execute_script(<<~JS, with)
      this.value = arguments[0]
      this.dispatchEvent(new Event("input", { bubbles: true }))
      this.dispatchEvent(new Event("change", { bubbles: true }))
    JS
  end

  # Clicks just after the script returns, so a confirm dialog the click opens
  # doesn't interrupt the driver's script call.
  def press(locator)
    find(:link_or_button, locator).execute_script("setTimeout(() => this.click())")
  end

  # Answers "OK" to the confirm dialog the block opens and checks it was
  # asked. A real dialog was sometimes dismissed by the driver before it could
  # be accepted, which cancels the action.
  def accept_confirm_dialog(message)
    page.execute_script("window.confirm = (text) => { window.confirmed = text; return true }")
    yield
    page.document.synchronize do
      asked = page.evaluate_script("window.confirmed")
      raise Capybara::ExpectationNotMet, "expected confirm #{message.inspect}, got #{asked.inspect}" unless asked == message
    end
  end

  def sign_in_as(user)
    visit new_session_url
    enter "email_address", with: user.email_address
    enter "password", with: "password"
    press "Sign in"
    assert_selector "h1", text: "Occasions"
  end
end
