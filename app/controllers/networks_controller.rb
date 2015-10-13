class NetworksController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
  	@networks = Network.order("network asc")
  end

  def new
    @network = Network.new
  end

  def create
    @network = Network.new(network_params)
    if @network.save
      flash[:success] = "Network added."
      redirect_to networks_url
    else
      render 'new'
    end
  end

  def edit
  	@network = Network.find_by_id(params[:id])
  end

  def update
  	@network = Network.find_by_id(params[:id])
    if @network.update_attributes(network_params)
      flash[:success] = "Network updated."
      redirect_to networks_url
    else
      render 'edit'
    end
  end

  def update_all
    if params[:update].present?
      @update = Network.update_all
      flash[:success] = @update
      redirect_to networks_url
    end    
  end

  def destroy
    Network.find_by_id(params[:id]).destroy
    flash[:success] = "Network deleted"
    redirect_to networks_url
  end

  private
    def network_params
      params.require(:network).permit(:network, :min, :max)
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