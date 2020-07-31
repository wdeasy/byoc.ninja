class GroupsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
  	@groups = Group.order(name: :asc)
  end

  def new
    @group = Group.new
  end

  def auto
    if params[:auto].present?
      @group = Group.auto_add(params[:url])
      if @group[0..4] == "Added"
        flash[:success] = @group
        redirect_to groups_url
      else
        flash[:danger] = @group
        redirect_to groups_auto_url
      end
    end
  end

  def create
      @group = Group.new(group_params)
      if @group.save
        flash[:success] = "Group added."
        redirect_to groups_url
      else
        render 'new'
      end
  end

  def edit
  	@group = Group.find(params[:id])
  end

  def update
  	@group = Group.find(params[:id])
    if @group.update_attributes(group_params)
      flash[:success] = "Group updated."
      redirect_to groups_url
    else
      render 'edit'
    end
  end

  def destroy
    Group.find(params[:id]).destroy
    flash[:success] = "Group deleted"
    redirect_to groups_url
  end


  private
    def group_params
      params.require(:group).permit(:steamid, :name, :url, :enabled)
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
