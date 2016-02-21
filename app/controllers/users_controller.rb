class UsersController < ApplicationController
  before_action :logged_in_user
  before_action :correct_user, :only => [:edit, :update]
  before_action :admin_user, :except => [:edit, :update]

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
    if User.is_member(@user) == false
      #flash[:info] = "You aren't a member of the Quakecon™ Steam Group!"
    end   
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

  private
    def user_params
      params.require(:user).permit(:display, :banned, :auto_update, :name, :url, :seat_id)
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