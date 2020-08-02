class UsersController < ApplicationController
  before_action :logged_in_user, :except => [:seat]
  #before_action :correct_user, :only => [:edit, :update]
  before_action :admin_user, :except => [:seat]

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
    if @user.update_attributes(user_params)
      flash[:success] = "User updated."
      redirect_to users_url
    else
      render 'edit'
    end
  end

  def seat
    @sections = Seat.all.order(sort: :asc).pluck(:section).uniq
  end

  private
    def user_params
      unless current_user.admin?
        params.extract!(:auto_update, :seat_id, :clan, :handle, :banned)
      end

      params.require(:user).permit(:display, :auto_update, :seat_id, :clan, :handle, :banned)
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
