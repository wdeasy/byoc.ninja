class UsersController < ApplicationController
  before_action :logged_in_user, :except => [:seat]
  #before_action :correct_user, :only => [:edit, :update]
  before_action :admin_user, :except => [:seat, :change_seat, :unlink_seat]

  def index
    @users = User.includes(:seat).where.not(host_id: nil).order(created_at: :desc)
    @users = User.includes(:seat).where(banned: true).order(created_at: :desc) if params[:banned].present?
    @users = User.includes(:seat).order(created_at: :desc) if params[:all].present?
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @seats = Seat.all.order(sort: :asc)
  end

  def update
  	@user = User.find(params[:id])
    Seat.mark_for_update(@user.seat.seat) if @user.seat.present?

    if @user.update(user_params)
      Seat.mark_for_update(@user.seat.seat) if @user.seat.present?
      flash[:success] = "User updated."
      redirect_to users_url
    else
      render 'edit'
    end
  end

  def seat
    @sections = Seat.all.order(sort: :asc).pluck(:section).uniq
  end

  def change_seat
    Seat.mark_for_update(current_user.seat.seat) if current_user.seat.present?    

    result = User.update_seat_from_omniauth(current_user.id, params['seat'])
    flash[result[:success] ? :success : :danger] = result[:message] unless result.nil?

    Seat.mark_for_update(params['seat']) if current_user.seat.present?

    redirect_to link_path
  end

  def unlink_seat
    Seat.mark_for_update(current_user.seat.seat) if current_user.seat.present?

    result = User.unlink_seat(current_user.id)
    flash[result[:success] ? :success : :danger] = result[:message] unless result.nil?

    redirect_to link_path
  end

  def ban
    @user = User.find(params[:id])
    if @user.update_attribute(:banned, true)
      flash[:success] = "User banned."
      redirect_to users_url
    else
      render 'edit'
    end
  end

  def unban
    @user = User.find(params[:id])
    if @user.update_attribute(:banned, false)
      flash[:success] = "User unbanned."
      redirect_to users_url
    else
      render 'edit'
    end
  end

  private
    def user_params
      unless current_user.admin?
        params.extract!(:auto_update, :seat_id, :clan, :handle)
      end

      params.require(:user).permit(:display, :auto_update, :seat_id, :clan, :handle)
    end

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

    def correct_user
      if !current_user.admin?
        @user = User.find(params[:id])
        redirect_to(root_url) unless @user == current_user
      end
    end
end
