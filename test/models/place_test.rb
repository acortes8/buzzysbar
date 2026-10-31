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
end
