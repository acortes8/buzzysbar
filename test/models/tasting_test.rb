require "test_helper"

class TastingTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile
  include ActiveJob::TestHelper

  setup do
    @tasting = tastings(:mai_tai_at_tiki_night)
  end

  test "requires a drink" do
    tasting = Tasting.new(occasion: occasions(:tiki_night))
    assert_not tasting.valid?
    assert_includes tasting.errors[:drink], "must exist"
  end

  test "rejects a photo that isn't an image" do
    @tasting.photo.attach(fixture_file_upload("notes.txt", "text/plain"))
    assert_not @tasting.valid?
    assert_includes @tasting.errors[:photo], "must be a JPEG, PNG, GIF, WebP, or HEIC image"
  end

  test "remove_photo removes the photo" do
    @tasting.update!(photo: fixture_file_upload("mai_tai.jpg", "image/jpeg"))
    perform_enqueued_jobs { @tasting.update!(remove_photo: true) }
    assert_not @tasting.reload.photo.attached?
  end

  test "a new photo wins over remove_photo" do
    @tasting.update!(photo: fixture_file_upload("mai_tai.jpg", "image/jpeg"))
    perform_enqueued_jobs { @tasting.update!(photo: fixture_file_upload("drink.heic", "image/heic"), remove_photo: true) }
    assert_equal "drink.heic", @tasting.reload.photo.filename.to_s
  end

  test "average score is the mean of its ratings" do
    @tasting.occasion.people << people(:guest)
    @tasting.ratings.create!(person: people(:guest), score: 3.5)
    assert_equal 4, @tasting.reload.average_score
  end

  test "average score is nil without ratings" do
    assert_nil Tasting.new.average_score
  end

  test "builds a rating for each person at the occasion who hasn't rated" do
    @tasting.occasion.people << people(:guest)
    @tasting.build_missing_ratings
    assert_equal [ people(:guest), people(:one) ], @tasting.ratings.map(&:person).sort_by(&:name)
    assert_equal 1, @tasting.ratings.count(&:new_record?)
  end

  test "ratings without a score or notes are skipped" do
    tasting = occasions(:tiki_night).tastings.build(drink: drinks(:saturn),
      ratings_attributes: [ { person_id: people(:one).id, score: "" } ])
    assert tasting.save
    assert_empty tasting.ratings
  end
end
