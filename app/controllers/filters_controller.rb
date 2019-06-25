class FiltersController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
  	@filters = Filter.order("name asc")
  end

  def new
    @filter = Filter.new
  end

  def create
    @filter = Filter.new(filter_params)
    if @filter.save
      flash[:success] = "Filter added."
      redirect_to filters_url
    else
      render 'new'
    end
  end

  def edit
  	@filter = Filter.find(params[:id])
  end

  def update
  	@filter = Filter.find(params[:id])
    if @filter.update_attributes(filter_params)
      flash[:success] = "Filter updated."
      redirect_to filters_url
    else
      render 'edit'
    end
  end

  def destroy
    Filter.find(params[:id]).destroy
    flash[:success] = "Filter deleted"
    redirect_to filters_url
  end

  private
    def filter_params
      params.require(:filter).permit(:name)
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
