require "test_helper"

class RatingTest < ActiveSupport::TestCase
  setup do
    @tasting = tastings(:mai_tai_at_tiki_night)
    @occasion = @tasting.occasion
    @occasion.people << people(:guest)
  end

  test "accepts scores from 1 to 5 in half points" do
    [ 1, 1.5, 3, 4.5, 5 ].each do |score|
      assert Rating.new(tasting: @tasting, person: people(:guest), score: score).valid?, "#{score} should be valid"
    end
  end

  test "rejects scores off the half-point scale" do
    [ 0.5, 4.3, 5.5 ].each do |score|
      rating = Rating.new(tasting: @tasting, person: people(:guest), score: score)
      assert_not rating.valid?, "#{score} should be invalid"
      assert_includes rating.errors[:score], "must be from 1 to 5 in half points"
    end
  end

  test "requires a score" do
    rating = Rating.new(tasting: @tasting, person: people(:guest))
    assert_not rating.valid?
    assert_includes rating.errors[:score], "can't be blank"
  end

  test "a person rates a tasting at most once" do
    rating = Rating.new(tasting: @tasting, person: people(:one), score: 3)
    assert_not rating.valid?
    assert_includes rating.errors[:person_id], "has already been taken"
  end

  test "only people at the occasion can rate" do
    stranger = Person.create!(name: "Stranger")
    rating = Rating.new(tasting: @tasting, person: stranger, score: 3)
    assert_not rating.valid?
    assert_includes rating.errors[:person], "wasn't at this occasion"
  end
end
