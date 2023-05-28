class IdentitiesController < ApplicationController
  before_action :logged_in_user, :except => [:qconbyoc]
  before_action :correct_user, :only => [:unlink]
  before_action :admin_user, :except => [:qconbyoc, :unlink, :link]

  def link
    @identities = Identity.where(:user_id => current_user.id, :enabled => true)
    @seat = current_user.seat.present? ? current_user.seat.seat : nil
  end

  def qconbyoc
    @taken = nil
    @invalid = nil
    @seat = nil

    if params[:seat].present?
      @seat = Seat.where(seat: params[:seat]).first
      if @seat.present?
        @user = User.where(seat_id: @seat.id).first
        unless @user.nil?
          @taken = @user.handle
        end
      else
        @invalid = true
      end
    end
  end

  def unlink
    @identity = Identity.find(params[:id])
    if @identity.update_attribute(:enabled, false)
      Seat.mark_for_update(@identity.user.seat.seat)
    else
      flash[:danger] = "Could not unlink account."
    end
    redirect_to link_path
  end

  def index
  	@identities = Identity.all.order(created_at: :desc)
    @identities = Identity.where(:provider => :steam).order(created_at: :desc) if params[:steam].present?
    @identities = Identity.where(:provider => :discord).order(created_at: :desc) if params[:discord].present?
    @identities = Identity.where(:provider => :bnet).order(created_at: :desc) if params[:bnet].present?
    @identities = Identity.where(:provider => :qconbyoc).order(created_at: :desc) if params[:qconbyoc].present?
    @identities = Identity.where(:banned => true).order(created_at: :desc) if params[:banned].present?
  end

  def edit
  	@identity = Identity.find(params[:id])
  end

  def update
  	@identity = Identity.find(params[:id])
    if @identity.update(identity_params)
      flash[:success] = "Identity updated."
      redirect_to identities_url
    else
      render 'edit'
    end
  end

  def destroy
    Identity.find_by_id(params[:id]).destroy
    flash[:success] = "Identity deleted"
    redirect_to identities_url
  end

  def ban
    @identity = Identity.find(params[:id])
    if @identity.update_attribute(:banned, true)
      flash[:success] = "Identity banned."
      redirect_to identities_url
    else
      render 'edit'
    end
  end

  def unban
    @identity = Identity.find(params[:id])
    if @identity.update_attribute(:banned, false)
      flash[:success] = "Identity unbanned."
      redirect_to identities_url
    else
      render 'edit'
    end
  end

  private

    def identity_params
      params.require(:identity).permit(:uid, :name, :enabled, :url, :avatar)
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

    def correct_user
      if !current_user.admin?
        @user = Identity.find(params[:id]).user
        redirect_to(root_url) unless @user == current_user
      end
    end
end
