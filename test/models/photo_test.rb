require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile

  test "accepts photos in phone and web formats" do
    assert occasions(:tiki_night).photos.new(image: fixture_file_upload("drink.heic", "image/heic")).valid?
    assert occasions(:tiki_night).photos.new(image: fixture_file_upload("mai_tai.jpg", "image/jpeg")).valid?
  end

  test "rejects files that aren't images" do
    photo = occasions(:tiki_night).photos.new(image: fixture_file_upload("notes.txt", "text/plain"))
    assert_not photo.valid?
    assert_equal [ "Photo must be a JPEG, PNG, GIF, WebP, or HEIC image" ], photo.errors.full_messages
  end

  test "requires an image" do
    assert_not occasions(:tiki_night).photos.new.valid?
  end

  test "photos at a bar can be published" do
    assert occasions(:tiki_night).photos.new(image: fixture_file_upload("mai_tai.jpg", "image/jpeg"), published: true).valid?
  end

  test "photos at home can't be published" do
    occasion = logbooks(:family).occasions.create!(place: places(:home))
    photo = occasion.photos.new(image: fixture_file_upload("mai_tai.jpg", "image/jpeg"), published: true)
    assert_not photo.valid?
    assert_includes photo.errors[:published], "is only for photos at bars"
  end
end
