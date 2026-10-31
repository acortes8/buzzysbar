require "test_helper"

class AttendanceTest < ActiveSupport::TestCase
  test "a person attends an occasion at most once" do
    attendance = Attendance.new(occasion: occasions(:tiki_night), person: people(:one))
    assert_not attendance.valid?
    assert_includes attendance.errors[:person_id], "has already been taken"
  end

  test "removing someone from an occasion removes their ratings there" do
    occasion = occasions(:tiki_night)
    assert_difference("Rating.count", -1) do
      occasion.update!(person_ids: [])
    end
  end
end
