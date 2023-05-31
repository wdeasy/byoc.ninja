class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => :create

  def login
  end

  def create
    if logged_in?
      @identity = Identity.update_with_omniauth(auth, current_user.id)
    else
      @identity = Identity.update_with_omniauth(auth)
      log_in @identity.user
    end

    if @identity.blank? || @identity.user.blank?
      flash.now[:danger] = 'Failed to create session.'
      redirect_to root_url
    end

    if param['seat']
      result = Identity.update(@identity.id, auth, param['seat'])
      flash[result[:success] ? :success : :danger] = result[:message] unless result.nil?
    else
      result = Identity.update(@identity.id, auth)
    end

    redirect_to link_path
  end

  def failure
  	flash.now[:danger] = 'Authentication Failure.'
  	redirect_to root_url
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

    def origin
      request.env['omniauth.origin']
    end

    def param
      request.env['omniauth.params']
    end

    def auth
      request.env['omniauth.auth']
    end
end
