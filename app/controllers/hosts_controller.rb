class HostsController < ApplicationController
  before_action :logged_in_user, :except => [:index, :json]
  before_action :admin_user, :except => [:index, :json]

  def index    
  	@hosts = Host.includes(:game, :users, :seats).where(visible: true).where("games.joinable = true").order("games.name ASC, users_count DESC, hosts.current IS NULL, hosts.current DESC, hosts.name DESC")
    
    respond_to do |format|
      format.html
      format.js
    end
  end

  def new
    @host = Host.new
  end

  def create
    @host = Host.new(add_params)
    @host = Host.manual_add(@host)

    if @host.save
      flash[:success] = "Host added."
      redirect_to hosts_url
    else
      render 'new'
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
    @hosts = Host.includes(:game, :users, :seats).where(visible: true).where("games.joinable = true").order("games.name ASC, users_count DESC, hosts.current IS NULL, hosts.current DESC, hosts.name DESC")
    render :json => @hosts
  end

  private
    def add_params
      params.require(:host).permit(:network_id, :address, :flags, :source, :game_name, :name, :pin)
    end

    def host_params
      params.require(:host).permit(:banned, :auto_update, :name, :map, :query_port, :network_id, :last_successful_query, :pin)
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