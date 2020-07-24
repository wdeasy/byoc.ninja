class UsersController < ApplicationController
  before_action :logged_in_user, :except => [:seat, :discord]
  before_action :correct_user, :only => [:edit, :update]
  before_action :admin_user, :except => [:edit, :update, :seat, :discord]

  def index
    @users = User.includes(:seat).where.not(host_id: nil).order("name ASC")
    @users = User.includes(:seat).where(banned: true).order("name ASC") if params[:banned].present?
    @users = User.includes(:seat).order("name ASC") if params[:all].present?
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @seats = Seat.where(:year => Date.today.year).order("sort asc")
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
    if cookies.signed[:hidden_message_ids].blank? || cookies.signed[:hidden_message_ids].include?("1")
      ids = [1, *cookies.signed[:hidden_message_ids]]
      cookies.permanent.signed[:hidden_message_ids] = ids
    end

    @sections = Seat.where(:year => Date.today.year).order("sort asc").pluck(:section).uniq
    if params[:link].present?
      result = User.update_seat(params[:seat], params[:url])
      if result[:success]
        flash[:success] = result[:message]
        redirect_to root_url
      else
        flash["danger"] = result[:message]
        redirect_to seat_url
      end
    end
  end

  def discord
    @sections = Seat.where(:year => Date.today.year).order("sort asc").pluck(:section).uniq
  end

  private
    def user_params
      unless current_user.admin?
        params.extract!(:auto_update)
      end

      params.require(:user).permit(:display, :auto_update, :name, :url, :seat_id, :discord_username)
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
