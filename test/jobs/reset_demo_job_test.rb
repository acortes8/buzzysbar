require "test_helper"
require "fugit" # Solid Queue parses schedules with it, but only loads it in the scheduler

class ResetDemoJobTest < ActiveJob::TestCase
  test "resets the demo logbook" do
    logbook = DemoLogbook.reset!
    logbook.places.create!(name: "A visitor's bar")

    ResetDemoJob.perform_now

    assert_not logbook.places.exists?(name: "A visitor's bar")
    assert_equal DemoLogbook::OCCASIONS.size, logbook.occasions.count
  end

  test "is scheduled nightly in production" do
    task = Rails.application.config_for("recurring", env: "production").fetch(:reset_demo)

    assert_equal ResetDemoJob, task[:class].constantize
    assert_equal "0 4 * * * America/Chicago", Fugit.parse_cronish(task[:schedule]).original
  end
end
