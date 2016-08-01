class ModsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
  	@mods = Mod.order("id asc")
  end

  def edit
  	@mod = Mod.find(params[:id])
  end

  def update
  	@mod = Mod.find(params[:id])
    if @mod.update_attributes(mod_params)
      flash[:success] = "Mod updated."
      redirect_to mods_url
    else
      render 'edit'
    end
  end

  def destroy
    Mod.find(params[:id]).destroy
    flash[:success] = "Mod deleted"
    redirect_to mods_url
  end


  private
    def mod_params
      params.require(:mod).permit(:name)
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