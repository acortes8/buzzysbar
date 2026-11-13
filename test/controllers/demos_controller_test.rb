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

  test "the demo can't see or change the family's recipes" do
    post demo_url
    recipe = recipes(:mai_tai)

    get recipe_url(recipe)
    assert_response :not_found

    patch recipe_url(recipe), params: { recipe: { title: "Vandalized" } }
    assert_response :not_found
    assert_equal "Mai Tai", recipe.reload.title
  end

  test "the demo can add recipes but not photos" do
    post demo_url

    post recipes_url, params: { recipe: {
      title: "Zombie", drink_name: "Zombie", ingredient_section: "Rums", instruction_section: "Shake",
      featured_image: fixture_file_upload("mai_tai.jpg", "image/jpeg")
    } }

    recipe = Recipe.last
    assert_equal DemoLogbook.user.logbook, recipe.logbook
    assert_not recipe.featured_image.attached?
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
