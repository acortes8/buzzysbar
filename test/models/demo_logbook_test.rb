require "test_helper"

class DemoLogbookTest < ActiveSupport::TestCase
  test "creates the demo user, logbook and records" do
    logbook = DemoLogbook.reset!

    assert_equal logbook, DemoLogbook.user.logbook
    assert_equal DemoLogbook::OCCASIONS.size, logbook.occasions.count
    assert_equal DemoLogbook::PEOPLE.sort, logbook.people.pluck(:name).sort
    assert_equal "You", DemoLogbook.user.person.name
    assert logbook.occasions.joins(tastings: :ratings).exists?
  end

  test "dates are counted back from today" do
    logbook = DemoLogbook.reset!
    assert_equal Date.current - 3, logbook.occasions.maximum(:occurred_on)
  end

  test "resetting replaces what visitors changed" do
    logbook = DemoLogbook.reset!
    logbook.places.create!(name: "A visitor's bar")
    logbook.occasions.first.update!(notes: "Changed by a visitor")
    logbook.users.create!(name: "Visitor", email_address: "visitor@example.com", password: "password")

    assert_equal logbook, DemoLogbook.reset!
    assert_not logbook.places.exists?(name: "A visitor's bar")
    assert_not logbook.occasions.exists?(notes: "Changed by a visitor")
    assert_equal [ DemoLogbook.user ], logbook.users.to_a
    assert_equal DemoLogbook::OCCASIONS.size, logbook.occasions.count
  end

  test "keeps the same demo user, so it stays signed in" do
    DemoLogbook.reset!
    user = DemoLogbook.user

    DemoLogbook.reset!
    assert_equal user, DemoLogbook.user
  end

  test "leaves other logbooks alone" do
    assert_no_difference([ "logbooks(:family).occasions.count", "logbooks(:family).people.count", "logbooks(:family).drinks.count" ]) do
      DemoLogbook.reset!
      DemoLogbook.reset!
    end
  end
end
