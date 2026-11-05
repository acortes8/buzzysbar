require "test_helper"

class RankingsControllerTest < ActionDispatch::IntegrationTest
  test "lists published drinks without signing in" do
    get rankings_url
    assert_response :success
    assert_select "#rankings a", text: "Mai Tai"
    assert_select "#rankings a", text: "Saturn", count: 0
  end

  test "shows a published drink's ranking without signing in" do
    get ranking_url(drinks(:mai_tai))
    assert_response :success
    assert_select "#ranking li", 1
    assert_match "The Tiki Hut", response.body
    assert_match "October 2026", response.body
    assert_match "4.5 / 5 from 1 rating", response.body
  end

  test "never shows people, notes or exact dates" do
    get ranking_url(drinks(:mai_tai))

    [ people(:one).name, ratings(:one_on_mai_tai).notes, tastings(:mai_tai_at_tiki_night).notes,
      occasions(:tiki_night).notes, "October 1" ].each do |private_text|
      assert_no_match private_text, response.body
    end
  end

  test "doesn't name homes" do
    occasion = logbooks(:family).occasions.create!(place: places(:home), occurred_on: "2026-10-15")
    occasion.tastings.create!(drink: drinks(:mai_tai))

    get ranking_url(drinks(:mai_tai))
    assert_select "#ranking li", text: /At home/
    assert_select "#ranking li", text: /#{places(:home).name}\b/, count: 0
  end

  test "unpublished drinks are not found" do
    get ranking_url(drinks(:saturn))
    assert_response :not_found
  end

  test "links published bars to their reviews" do
    get ranking_url(drinks(:mai_tai))
    assert_select "#ranking a[href=?]", bar_path(places(:bar)), text: "The Tiki Hut"
  end

  test "shows only published photos" do
    tasting = tastings(:mai_tai_at_tiki_night)
    tasting.update!(photo: fixture_file_upload("mai_tai.jpg", "image/jpeg"))

    get ranking_url(drinks(:mai_tai))
    assert_select "#ranking img", count: 0

    tasting.update!(photo_published: true)
    get ranking_url(drinks(:mai_tai))
    assert_select "#ranking img[alt=?]", "Photo of Mai Tai"
  end
end
