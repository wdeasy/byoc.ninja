class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => :create

  def login
  end

  def create
    auth = request.env['omniauth.auth']

    if logged_in?
      @identity = Identity.find_with_omniauth(auth, current_user.id)
    else
      @identity = Identity.find_with_omniauth(auth)
    end

    if @identity.nil?
      @identity = Identity.create_with_omniauth(auth)
    end

    if logged_in?
      unless @identity.user == current_user
        @identity.user = current_user
        @identity.save
      end
    else
      if @identity.user.present?
        log_in @identity.user
      else
        user = User.create_with_omniauth
        if user
          log_in user
          @identity.user = current_user
          @identity.save
        else
          flash.now[:danger] = 'Failed to create session.'
        end
      end
    end

    if logged_in?
      @identity.update_info(auth)
      User.update_with_omniauth(@identity.user_id, @identity.name)
      if @identity.discord?
        Identity.update_connections(auth.credentials.token, @current_user.id)
      end

      if request.env['omniauth.params']['seat'].present?
        result = User.update_seat_from_omniauth(@identity.user_id, request.env['omniauth.params']['seat'])
        flash[result[:success] ? :success : :danger] = result[:message]
      end

      if request.env['omniauth.params']['uid'].present?
        Identity.create_with_qconbyoc(@identity.user_id, request.env['omniauth.params']['uid'])
      end

      Identity.update_qconbyoc(@identity.user_id)
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
end
