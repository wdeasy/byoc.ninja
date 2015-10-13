class ProtocolsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
  	@protocols = Protocol.order("name ASC")
  end

  def edit
    @protocol = Protocol.find_by_id(params[:id])
  end

  def update
    @protocol = Protocol.find_by_id(params[:id])
    if @protocol.update_attributes(protocol_params)
      flash[:success] = "Protocol updated."
      redirect_to protocols_url
    else
      render 'edit'
    end
  end

  def query
    @protocols = Protocol.order("name ASC")
    @query = Protocol.query_server(params[:protocol],params[:ip],params[:port]) if params[:ip].present? && params[:port].present?
  end

  private
    def protocol_params
      params.require(:protocol).permit(:host, :map, :num, :max, :pass, :port, :players, :playername)
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