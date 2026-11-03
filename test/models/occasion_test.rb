require "test_helper"

class OccasionTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile
  test "defaults to today" do
    assert_equal Date.current, Occasion.new.occurred_on
  end

  test "requires a place and a date" do
    occasion = Occasion.new(place: nil, occurred_on: nil)
    assert_not occasion.valid?
    assert_includes occasion.errors[:place], "must exist"
    assert_includes occasion.errors[:occurred_on], "can't be blank"
  end

  test "does not require anyone to have come" do
    assert logbooks(:family).occasions.new(place: places(:home)).valid?
  end

  test "the place must be in the same logbook" do
    occasion = logbooks(:family).occasions.new(place: places(:neighbors_bar))
    assert_not occasion.valid?
    assert_includes occasion.errors[:place], "must be in the same logbook"
  end

  test "accepts photos in phone and web formats" do
    occasion = occasions(:tiki_night)
    occasion.photos.attach(fixture_file_upload("drink.heic", "image/heic"), fixture_file_upload("mai_tai.jpg", "image/jpeg"))
    assert occasion.valid?
  end

  test "rejects files that aren't images" do
    occasion = occasions(:tiki_night)
    occasion.photos.attach(fixture_file_upload("notes.txt", "text/plain"))
    assert_not occasion.valid?
    assert_includes occasion.errors[:photos], "must be a JPEG, PNG, GIF, WebP, or HEIC image"
  end

  test "title names the place and date" do
    assert_equal "The Tiki Hut, October 1st, 2026", occasions(:tiki_night).title
  end
end
