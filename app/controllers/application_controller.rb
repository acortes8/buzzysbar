class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :demo?

  private
    def demo?
      authenticated? && Current.user.demo?
    end

    # Demo visitors are anonymous, so they can't change anything outside the
    # demo logbook (like the public recipes or user accounts) or upload files.
    def prevent_in_demo
      redirect_back_or_to root_path, alert: "That's turned off in the demo." if demo?
    end
end
