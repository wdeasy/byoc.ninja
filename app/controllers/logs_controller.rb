class LogsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def update_hosts
  end

  def update_seats
  end

  private
    # Confirms a logged-in user.
    def logged_in_user
      unless logged_in?
        store_location
        redirect_to root_url
      end
    end

    # Confirms an admin user.
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end 
end