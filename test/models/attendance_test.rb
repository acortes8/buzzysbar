require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  test "a person attends an occasion at most once" do
    attendance = Attendance.new(occasion: occasions(:tiki_night), person: people(:one))
    assert_not attendance.valid?
    assert_includes attendance.errors[:person_id], "has already been taken"
  end
end
