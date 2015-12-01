class HostsController < ApplicationController
  before_action :logged_in_user, :except => [:index, :json, :list]
  before_action :admin_user, :except => [:index, :json, :list]

  def index
  	@hosts = Host.includes(:game).where(visible: true).order("games.gameextrainfo ASC, users_count DESC, gameserverip ASC")
    @messages = Message.where(show: true).order("updated_at desc")

    if current_user && current_user.seat.blank?
      flash[:info] = "Click on your name in the top right corner and go to the settings page to set your BYOC seat!"
    end
    
  	respond_to do |format|
      format.html
      format.js
      format.json
    end
  end

  def edit
  	@host = Host.find_by_slug(params[:gameserverip])
  end

  def update
  	@host = Host.find_by_slug(params[:gameserverip])
    if @host.update_attributes(host_params)
      flash[:success] = "Host updated."
      redirect_to admin_hosts_url
    else
      render 'edit'
    end
  end

  def json
    @hosts = Host.includes(:game).where(visible: true).order("games.gameextrainfo ASC, users_count DESC, gameserverip ASC")
    #@messages = Message.where(show: true).order("updated_at desc")

    render :json => @hosts
  end

  #test page for json server browser
  def list
  end

  private
    def host_params
      params.require(:host).permit(:banned, :auto_update, :name, :map, :query_port, :refresh, :network, :last_successful_query, :tried_query)
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