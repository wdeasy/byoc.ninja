class IdentitiesController < ApplicationController
  before_action :logged_in_user, :except => [:qconbyoc]

  def link
    @identities = Identity.where(:user_id => current_user.id, :enabled => true)
  end

  def qconbyoc
    @seat = params[:seat].present? ? params[:seat] : nil
    @uid = params[:uid].present? ? params[:uid] : nil
  end

  private
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
