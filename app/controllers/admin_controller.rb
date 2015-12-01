class AdminController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def host
    @hosts = Host.includes(:game).where(visible: true).order("games.gameextrainfo ASC, gameserverip ASC")
    @hosts = Host.includes(:game).where(banned: true).order("games.gameextrainfo ASC, gameserverip ASC") if params[:banned].present?
    @hosts = Host.includes(:game).order("games.gameextrainfo ASC, gameserverip ASC") if params[:all].present?
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