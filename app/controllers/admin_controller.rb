class AdminController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def hosts
    @hosts = Host.includes(:game).where(visible: true).order("games.name ASC, address ASC")
    @hosts = Host.includes(:game).where(banned: true).order("games.name ASC, address ASC") if params[:banned].present?
    @hosts = Host.includes(:game).where(source: :manual).order("games.name ASC, address ASC") if params[:manual].present?
    @hosts = Host.includes(:game).where(pin: true).order("games.name ASC, address ASC") if params[:pinned].present?
    @hosts = Host.includes(:game).order("games.name ASC, address ASC") if params[:all].present?
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
