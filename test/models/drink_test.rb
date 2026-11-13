require "test_helper"

class DrinkTest < ActiveSupport::TestCase
  test "requires a name" do
    drink = Drink.new(name: "")
    assert_not drink.valid?
    assert_includes drink.errors[:name], "can't be blank"
  end

  test "does not require a description" do
    assert logbooks(:family).drinks.new(name: "Zombie").valid?
  end

  test "names are unique regardless of case and spacing" do
    drink = logbooks(:family).drinks.new(name: "  mai   TAI ")
    assert_not drink.valid?
    assert_includes drink.errors[:name], "has already been taken"
  end

  test "another logbook can use the same name" do
    assert logbooks(:neighbors).drinks.new(name: "Saturn").valid?
  end

  test "squishes extra whitespace from names" do
    assert_equal "Jungle Bird", Drink.new(name: "  Jungle   Bird ").name
  end

  test "published lists only published drinks" do
    assert_equal [ drinks(:mai_tai) ], Drink.published.to_a
  end

  test "ranks tastings by average score, unrated last" do
    drink = drinks(:mai_tai)
    occasion = logbooks(:family).occasions.create!(place: places(:home), occurred_on: "2026-10-15", people: [ people(:one) ])
    unrated = occasion.tastings.create!(drink: drink)
    better = occasion.tastings.create!(drink: drink, ratings_attributes: [ { person: people(:one), score: 5 } ])

    assert_equal [ better, tastings(:mai_tai_at_tiki_night), unrated ], drink.reload.ranked_tastings
  end

  test "find_or_initialize_by_name finds a drink ignoring case and spacing" do
    assert_equal drinks(:mai_tai), logbooks(:family).drinks.find_or_initialize_by_name("  mai   TAI ")
  end

  test "find_or_initialize_by_name builds a new drink in the logbook" do
    drink = logbooks(:family).drinks.find_or_initialize_by_name(" Jungle  Bird ")
    assert drink.new_record?
    assert_equal "Jungle Bird", drink.name
    assert_equal logbooks(:family), drink.logbook
  end

  test "can't be deleted while it has recipes" do
    drink = drinks(:mai_tai)
    drink.tastings.destroy_all
    assert_not drink.destroy
    assert_includes drink.errors[:base], "Can't be deleted while it has recipes"
  end
end
