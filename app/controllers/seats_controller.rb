class SeatsController < ApplicationController
  before_action :logged_in_user, :except => [:lookup]
  before_action :admin_user, :except => [:lookup]

  def index
	@seats = Seat.order(sort: :asc)
	@seats = Seat.order(sort_column) if params[:sort].present?
  end

  def update
    if params[:update].present?
      @update = Seat.update_seats(nil,nil)
      flash[:success] = @update
      redirect_to seats_update_url
    end
  end

  def lookup
    @seats = []

    if params[:row].present? && params[:section].present?
      @seats = Seat.where(section: params[:section], row: params[:row]).order(sort: :asc)
    elsif params[:section].present?
      @seats = Seat.where(section: params[:section]).order(sort: :asc).pluck(:row).uniq
    end

    respond_to do |format|
      format.json { render :json => @seats.as_json(:only => [:seat, :section, :row, :number]) }
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

    def sort_column
      Seat.column_names.include?(params[:sort]) ? params[:sort] : "sort"
    end
end
