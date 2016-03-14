class HostsController < ApplicationController
  before_action :logged_in_user, :except => [:index, :json]
  before_action :admin_user, :except => [:index, :json]

  def index
  	@hosts = Host.includes(:game, :users, :seats).where(visible: true).where("users_count > ?", 0).order("games.name ASC, users_count DESC, address ASC")
    @messages = Message.where(show: true).order("updated_at desc")

    #if current_user && current_user.seat_id.blank?
    #  flash[:info] = "Click on your name in the top right corner and go to the settings page to set your BYOC seat!"
    #end
    
  	respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
  	@host = Host.find_by_id(params[:id])
  end

  def update
  	@host = Host.find_by_id(params[:id])
    if @host.update_attributes(host_params)
      flash[:success] = "Host updated."
      redirect_to admin_hosts_url
    else
      render 'edit'
    end
  end

  def json
    @hosts = Host.includes(:game, :users, :seats).where( visible: true ).where( "users_count > ?", 0 ).order("games.name ASC, users_count DESC, address ASC")
    render :json => @hosts
  end

  private
    def host_params
      params.require(:host).permit(:banned, :auto_update, :name, :map, :query_port, :network, :last_successful_query, :tried_query)
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