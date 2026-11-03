require "test_helper"

class LogbookTest < ActiveSupport::TestCase
  test "requires a name" do
    logbook = Logbook.new(name: "")
    assert_not logbook.valid?
    assert_includes logbook.errors[:name], "can't be blank"
  end
end
