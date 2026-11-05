require "test_helper"

class BarsControllerTest < ActionDispatch::IntegrationTest
  test "lists published bars without signing in" do
    logbooks(:family).places.create!(name: "Secret Lounge")

    get bars_url
    assert_response :success
    assert_select "#bars a", text: "The Tiki Hut"
    assert_select "#bars a", text: "Secret Lounge", count: 0
  end

  test "shows a published bar's review without signing in" do
    get bar_url(places(:bar))
    assert_response :success
    assert_select "#review", text: places(:bar).review
    assert_match "1 visit, most recently October 2026", response.body
    assert_select "#drinks li", text: /Mai Tai.*4\.5 \/ 5/m
  end

  test "links drinks that have a public ranking" do
    get bar_url(places(:bar))
    assert_select "#drinks a[href=?]", ranking_path(drinks(:mai_tai))
  end

  test "never shows people, notes or exact dates" do
    get bar_url(places(:bar))

    [ people(:one).name, ratings(:one_on_mai_tai).notes, tastings(:mai_tai_at_tiki_night).notes,
      occasions(:tiki_night).notes, "October 1" ].each do |private_text|
      assert_no_match private_text, response.body
    end
  end

  test "unpublished bars are not found" do
    get bar_url(logbooks(:family).places.create!(name: "Secret Lounge"))
    assert_response :not_found
  end

  test "homes are not found even if marked published" do
    places(:home).update_column(:published, true)

    get bar_url(places(:home))
    assert_response :not_found
  end

  test "shows only published photos" do
    tasting = tastings(:mai_tai_at_tiki_night)
    tasting.update!(photo: fixture_file_upload("mai_tai.jpg", "image/jpeg"))

    get bar_url(places(:bar))
    assert_select "#photos img", count: 0

    tasting.update!(photo_published: true)
    get bar_url(places(:bar))
    assert_select "#photos img[alt=?]", "Photo of Mai Tai"
  end

  test "shows only published occasion photos" do
    photo = occasions(:tiki_night).photos.create!(image: fixture_file_upload("mai_tai.jpg", "image/jpeg"))

    get bar_url(places(:bar))
    assert_select "#photos img", count: 0

    photo.update!(published: true)
    get bar_url(places(:bar))
    assert_select "#photos img[alt=?]", "Photo from The Tiki Hut"
  end
end
