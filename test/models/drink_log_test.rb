require "test_helper"

class DrinkLogTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile

  test "requires a place and a drink" do
    log = DrinkLog.new
    assert_not log.save
    assert_includes log.errors[:place_name], "can't be blank"
    assert_includes log.errors[:drink_name], "can't be blank"
  end

  test "defaults to today" do
    assert_equal Date.current, DrinkLog.new.occurred_on
  end

  test "creates the place, drink, and occasion when they're new" do
    log = DrinkLog.new(place_name: "Lost Lake", drink_name: "Zombie")

    assert_difference([ "Place.count", "Drink.count", "Occasion.count", "Tasting.count" ], 1) do
      assert log.save
    end
    assert log.tasting.occasion.place.bar?
    assert_equal Date.current, log.tasting.occasion.occurred_on
  end

  test "reuses existing names regardless of case and spacing" do
    log = DrinkLog.new(place_name: " the tiki HUT ", drink_name: "mai  tai", occurred_on: occasions(:tiki_night).occurred_on)

    assert_no_difference([ "Place.count", "Drink.count", "Occasion.count" ]) do
      assert log.save
    end
    assert_equal occasions(:tiki_night), log.tasting.occasion
    assert_equal drinks(:mai_tai), log.tasting.drink
  end

  test "a different date at the same place is a new occasion" do
    log = DrinkLog.new(place_name: "The Tiki Hut", drink_name: "Saturn", occurred_on: Date.new(2026, 10, 2))
    assert_difference("Occasion.count", 1) { assert log.save }
  end

  test "adds checked and newly named people without removing anyone" do
    log = DrinkLog.new(place_name: "The Tiki Hut", drink_name: "Saturn", occurred_on: occasions(:tiki_night).occurred_on,
      person_ids: [ "", people(:guest).id.to_s ], other_people: "Sam, guest, , sam")

    assert_difference("Person.count", 1) { assert log.save }
    assert_equal %w[ Guest One Sam ], occasions(:tiki_night).people.order(:name).pluck(:name)
  end

  test "an invalid photo saves nothing" do
    log = DrinkLog.new(place_name: "Lost Lake", drink_name: "Zombie", photo: fixture_file_upload("notes.txt", "text/plain"))

    assert_no_difference([ "Place.count", "Drink.count", "Occasion.count", "Tasting.count" ]) do
      assert_not log.save
    end
    assert_includes log.errors[:base], "Photo must be a JPEG, PNG, GIF, WebP, or HEIC image"
  end

  test "for_occasion starts from the occasion's place, date, and people" do
    log = DrinkLog.for_occasion(occasions(:tiki_night))
    assert_equal "The Tiki Hut", log.place_name
    assert_equal occasions(:tiki_night).occurred_on, log.occurred_on
    assert_equal [ people(:one).id ], log.person_ids
  end
end
