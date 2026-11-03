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
end
