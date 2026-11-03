require "test_helper"

class LogbookTest < ActiveSupport::TestCase
  test "requires a name" do
    logbook = Logbook.new(name: "")
    assert_not logbook.valid?
    assert_includes logbook.errors[:name], "can't be blank"
  end

  test "destroying a logbook destroys its records" do
    logbook = logbooks(:family)
    logbook.destroy!

    assert_not Occasion.exists?(logbook_id: logbook.id)
    assert_not Person.exists?(logbook_id: logbook.id)
    assert_not User.exists?(logbook_id: logbook.id)
  end
end
