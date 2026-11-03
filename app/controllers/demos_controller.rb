# "Try the demo": signs visitors in to the demo logbook without a password.
class DemosController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, with: -> { redirect_to new_session_url, alert: "Try again later." }

  # POST /demo
  def create
    terminate_session if authenticated?
    DemoLogbook.reset! unless DemoLogbook.user
    start_new_session_for DemoLogbook.user
    redirect_to root_path
  end
end
