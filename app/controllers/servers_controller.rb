class ServersController < ApplicationController
  before_action :logged_in_user, except: :index
  before_action :admin_user, except: :index

  def index
  	@servers = Server.includes(:game).where(visible: true).order("games.gameextrainfo ASC, users_count DESC, gameserverip ASC")
    @messages = Message.where(show: true).order("updated_at desc")

    if current_user && current_user.seat.blank?
      flash[:info] = "Click on your name in the top right corner and go to the settings page to set your BYOC seat!"
    end
    
  	respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
  	@server = Server.find_by_slug(params[:gameserverip])
  end

  def update
  	@server = Server.find_by_slug(params[:gameserverip])
    if @server.update_attributes(server_params)
      flash[:success] = "Server updated."
      redirect_to admin_servers_url
    else
      render 'edit'
    end
  end

  private
    def server_params
      params.require(:server).permit(:banned, :auto_update, :name, :map, :query_port, :refresh, :network, :last_successful_query, :tried_query)
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
end