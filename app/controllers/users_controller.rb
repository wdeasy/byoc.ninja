class UsersController < ApplicationController
  before_action :logged_in_user, :except => [:seat, :discord]
  before_action :correct_user, :only => [:edit, :update]
  before_action :admin_user, :except => [:edit, :update, :seat, :discord]

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
    @identities = Identity.where(:user_id => params[:id], :enabled => true)
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

  def seat
    @sections = Seat.all.order("sort asc").pluck(:section).uniq
    if params[:link].present?
      result = User.update_seat(params[:seat], params[:url])
      if result[:success]
        flash[:success] = result[:message]
        redirect_to root_url
      else
        flash[:danger] = result[:message]
        redirect_to seat_url
      end
    end
  end

  def discord
    @sections = Seat.all.order(sort: :asc).pluck(:section).uniq
  end

  private
    def user_params
      unless current_user.admin?
        params.extract!(:display)
      end

      params.require(:user).permit(:display, :auto_update, :seat_id)
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
