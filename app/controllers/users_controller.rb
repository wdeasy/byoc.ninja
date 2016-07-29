class UsersController < ApplicationController
  before_action :logged_in_user, :except => [:seat]
  before_action :correct_user, :only => [:edit, :update]
  before_action :admin_user, :except => [:edit, :update, :seat]

  def index  	
    @users = User.includes(:seats).where.not(host_id: nil).order("name ASC")
    @users = User.includes(:seats).where(banned: true).order("name ASC") if params[:banned].present?     
    @users = User.includes(:seats).order("name ASC") if params[:all].present?  
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
    @seats = Seat.where(:year => Date.today.year).order("seat asc")
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
    if cookies.signed[:hidden_message_ids].blank? || cookies.signed[:hidden_message_ids].include?("1")
      ids = [1, *cookies.signed[:hidden_message_ids]]
      cookies.permanent.signed[:hidden_message_ids] = ids 
    end

    @seats = Seat.where(:year => Date.today.year).order("seat asc")
    if params[:link].present?
      @user = User.update_seat(params[:user][:seat_id],params[:url])
      if @user[0..12] == "You're linked"
        flash["success"] = @user
        redirect_to root_url
      else
        flash["danger"] = @user
        redirect_to seat_url
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:display, :banned, :auto_update, :name, :url, :seat_ids)
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