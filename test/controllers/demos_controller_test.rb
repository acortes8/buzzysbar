require "test_helper"

class DemosControllerTest < ActionDispatch::IntegrationTest
  include ActionMailer::TestHelper

  test "the sign-in page offers the demo" do
    get new_session_url
    assert_select "form[action=?] button", demo_path, text: "Try the demo"
  end

  test "signs in to the demo, building it if needed" do
    assert_nil DemoLogbook.user

    post demo_url
    assert_redirected_to root_url

    follow_redirect!
    assert_select "#demo-banner"
    assert_match "The Coconut Lantern", response.body
    assert_no_match occasions(:tiki_night).place.name, response.body
  end

  test "signing in to the demo signs out of another account" do
    login_as users(:one)
    post demo_url

    get occasions_url
    assert_select "#demo-banner"
  end

  test "real accounts don't see the demo banner" do
    login_as users(:one)
    get occasions_url
    assert_select "#demo-banner", count: 0
  end

  test "the demo can't change recipes" do
    post demo_url
    beverage = beverages(:mai_tai)

    get new_beverage_url
    assert_redirected_to root_url
    assert_equal "That's turned off in the demo.", flash[:alert]

    patch beverage_url(beverage), params: { beverage: { title: "Vandalized" } }
    assert_equal "Mai Tai", beverage.reload.title

    assert_no_difference("Beverage.count") do
      delete beverage_url(beverage)
    end

    get beverages_url
    assert_select "a[href=?]", edit_beverage_path(beverage), count: 0
    assert_select "a[href=?]", new_beverage_path, count: 0
  end

  test "the demo can't manage users" do
    post demo_url

    assert_no_difference("User.count") do
      post users_url, params: { user: { name: "Visitor", email_address: "visitor@example.com", password: "secret", password_confirmation: "secret" } }
    end
    assert_redirected_to root_url

    patch user_url(DemoLogbook.user), params: { user: { email_address: "taken@example.com" } }
    assert_equal DemoLogbook::EMAIL_ADDRESS, DemoLogbook.user.reload.email_address

    assert_no_difference("User.count") do
      delete user_url(DemoLogbook.user)
    end

    get users_url
    assert_response :success
    assert_select "a[href=?]", new_user_path, count: 0
  end

  test "the demo can't upload photos" do
    post demo_url
    occasion = DemoLogbook.user.logbook.occasions.first
    photo = fixture_file_upload("mai_tai.jpg", "image/jpeg")

    post occasion_photos_url(occasion), params: { photos: [ photo ] }
    assert_not occasion.photos.exists?

    post log_url, params: { drink_log: { place_name: "Lava Room", drink_name: "Zombie", photo: photo } }
    assert_response :redirect
    assert_not occasion.logbook.occasions.joins(tastings: :photo_attachment).exists?

    tasting = occasion.tastings.first
    patch occasion_tasting_url(occasion, tasting), params: { tasting: { notes: "Changed", photo: photo } }
    assert_equal "Changed", tasting.reload.notes
    assert_not tasting.photo.attached?

    get occasion_url(occasion)
    assert_select "input[type=file]", count: 0
  end

  test "the demo can still log and edit drinks" do
    post demo_url

    assert_difference("Tasting.count") do
      post log_url, params: { drink_log: { place_name: "Lava Room", drink_name: "Zombie" } }
    end
  end

  test "no password reset email for the demo account" do
    DemoLogbook.reset!

    assert_no_enqueued_emails do
      post passwords_url, params: { email_address: DemoLogbook::EMAIL_ADDRESS }
    end
  end
end
