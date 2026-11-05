require "test_helper"

class Occasions::PhotosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @occasion = occasions(:tiki_night)
    login_as users(:one)
  end

  test "should add several photos at once" do
    post occasion_photos_url(@occasion), params: {
      photos: [ fixture_file_upload("mai_tai.jpg", "image/jpeg"), fixture_file_upload("drink.heic", "image/heic") ]
    }

    assert_redirected_to occasion_url(@occasion)
    assert_equal "2 photos added.", flash[:notice]
    assert_equal 2, @occasion.reload.photos.count
  end

  test "should not add files that aren't images" do
    post occasion_photos_url(@occasion), params: { photos: [ fixture_file_upload("notes.txt", "text/plain") ] }

    assert_redirected_to occasion_url(@occasion)
    assert_equal "Photo must be a JPEG, PNG, GIF, WebP, or HEIC image", flash[:alert]
    assert_equal 0, @occasion.reload.photos.count
  end

  test "should ask for a photo when none was chosen" do
    post occasion_photos_url(@occasion), params: { photos: [ "" ] }

    assert_redirected_to occasion_url(@occasion)
    assert_equal "Choose at least one photo.", flash[:alert]
  end

  test "should not add any photos if one isn't an image" do
    post occasion_photos_url(@occasion), params: {
      photos: [ fixture_file_upload("mai_tai.jpg", "image/jpeg"), fixture_file_upload("notes.txt", "text/plain") ]
    }

    assert_equal 0, @occasion.reload.photos.count
  end

  test "should remove a photo" do
    photo = @occasion.photos.create!(image: fixture_file_upload("mai_tai.jpg", "image/jpeg"))

    delete occasion_photo_url(@occasion, photo)

    assert_redirected_to occasion_url(@occasion)
    assert_equal 0, @occasion.reload.photos.count
  end

  test "occasion page shows its photos" do
    @occasion.photos.create!(image: fixture_file_upload("mai_tai.jpg", "image/jpeg"))

    get occasion_url(@occasion)
    assert_select "img[alt=?]", "Photo from #{@occasion.title}"
  end

  test "should publish and unpublish a photo" do
    photo = @occasion.photos.create!(image: fixture_file_upload("mai_tai.jpg", "image/jpeg"))

    patch occasion_photo_url(@occasion, photo), params: { photo: { published: true } }
    assert_redirected_to occasion_url(@occasion)
    assert photo.reload.published?

    patch occasion_photo_url(@occasion, photo), params: { photo: { published: false } }
    assert_not photo.reload.published?
  end

  test "should not publish a photo from home" do
    occasion = logbooks(:family).occasions.create!(place: places(:home))
    photo = occasion.photos.create!(image: fixture_file_upload("mai_tai.jpg", "image/jpeg"))

    get occasion_url(occasion)
    assert_select "button", text: "Publish", count: 0

    patch occasion_photo_url(occasion, photo), params: { photo: { published: true } }
    assert_equal "Published is only for photos at bars", flash[:alert]
    assert_not photo.reload.published?
  end

  test "demo visitors can't publish photos" do
    post demo_url
    occasion = DemoLogbook.user.logbook.occasions.joins(:place).merge(Place.bar).first
    photo = occasion.photos.create!(image: fixture_file_upload("mai_tai.jpg", "image/jpeg"))

    patch occasion_photo_url(occasion, photo), params: { photo: { published: true } }
    assert_not photo.reload.published?
  end
end
