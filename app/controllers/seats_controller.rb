class SeatsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
	@seats = Seat.order("seat asc")
	@seats = Seat.order(params[:sort])  if params[:sort].present?
  end

  def update
    if params[:update].present?
      @update = Seat.update_seats
      flash[:success] = @update
      redirect_to seats_update_url
    end
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