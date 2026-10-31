require "test_helper"

class TastingTest < ActiveSupport::TestCase
  setup do
    @tasting = tastings(:mai_tai_at_tiki_night)
  end

  test "requires a drink" do
    tasting = Tasting.new(occasion: occasions(:tiki_night))
    assert_not tasting.valid?
    assert_includes tasting.errors[:drink], "must exist"
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
