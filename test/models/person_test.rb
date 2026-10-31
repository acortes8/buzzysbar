require "test_helper"

class PersonTest < ActiveSupport::TestCase
  test "requires a name" do
    person = Person.new(name: "")
    assert_not person.valid?
    assert_includes person.errors[:name], "can't be blank"
  end

  test "does not require an account" do
    assert Person.new(name: "Friend").valid?
  end

  test "an account belongs to at most one person" do
    person = Person.new(name: "Duplicate", user: people(:one).user)
    assert_not person.valid?
    assert_includes person.errors[:user_id], "has already been taken"
  end
end
