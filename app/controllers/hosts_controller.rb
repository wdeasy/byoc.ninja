class HostsController < ApplicationController
  before_action :logged_in_user, :except => [:index]
  before_action :admin_user, :except => [:index]

  def index
  	@hosts = Host.includes(:game, :mod, :users, :seats).active.order("games.name ASC, hosts.users_count DESC, hosts.current DESC, hosts.current DESC, hosts.name ASC")
  end

  def new
    @host = Host.new
  end

  def create
    @host = Host.new(add_params)
    @host.pin = true
    @host.visible = true
    @host.updated = true
    @host.source = :manual
    flags = {}
    flags[:manual] = true
    @host.flags = flags

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

  def ban
    @host = Host.find(params[:id])
    if @host.update_attribute(:banned, true)
      flash[:success] = "Host banned."
      redirect_to admin_hosts_url
    else
      render 'edit'
    end
  end

  def unban
    @host = Host.find(params[:id])
    if @host.update_attribute(:banned, false)
      flash[:success] = "Host unbanned."
      redirect_to admin_hosts_url
    else
      render 'edit'
    end
  end

  private
    def add_params
      params.require(:host).permit(:game_id, :network_id, :address, :source, :name, :pin, :visible, :updated, :flags)
    end

    def host_params
      params.require(:host).permit(:auto_update, :name, :map, :query_port, :network_id, :last_successful_query, :pin, :source)
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
