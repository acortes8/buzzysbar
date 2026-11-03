# Runs nightly (see config/recurring.yml) so visitors' changes to the demo
# don't pile up.
class ResetDemoJob < ApplicationJob
  def perform
    DemoLogbook.reset!
  end
end
