require "test_helper"

class PlaceTest < ActiveSupport::TestCase
  test "requires a name" do
    place = Place.new(name: "", kind: "bar")
    assert_not place.valid?
    assert_includes place.errors[:name], "can't be blank"
  end

  test "defaults to a bar" do
    assert Place.new(name: "Somewhere").bar?
  end

  test "rejects unknown kinds" do
    place = Place.new(name: "Somewhere", kind: "boat")
    assert_not place.valid?
    assert_includes place.errors[:kind], "is not included in the list"
  end

  test "only bars can be published" do
    assert places(:bar).valid?

    home = places(:home)
    home.published = true
    assert_not home.valid?
    assert_includes home.errors[:published], "is only for bars"
  end

  test "published lists only published places" do
    assert_equal [ places(:bar) ], Place.published.to_a
  end

  test "scores each drink by the average of its tastings, best first" do
    bar = places(:bar)
    occasion = logbooks(:family).occasions.create!(place: bar, occurred_on: "2026-10-15", people: [ people(:one) ])
    occasion.tastings.create!(drink: drinks(:mai_tai), ratings_attributes: [ { person: people(:one), score: 3.5 } ])
    occasion.tastings.create!(drink: drinks(:saturn), ratings_attributes: [ { person: people(:one), score: 5 } ])

    scores = bar.drink_scores
    assert_equal [ drinks(:saturn), drinks(:mai_tai) ], scores.map(&:drink)
    assert_equal [ 5, 4 ], scores.map(&:average_score)
    assert_equal [ 1, 2 ], scores.map(&:tastings_count)
  end
end
