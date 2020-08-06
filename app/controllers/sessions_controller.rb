class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => :create

  def login
  end

  def create
    @identity = Identity.find_with_omniauth(auth)
    if logged_in? && @identity.nil?
      @identity = Identity.find_with_omniauth(auth, current_user.id)
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

    if logged_in? && !@current_user.banned? && !@identity.banned?
      @identity.update_info(auth)
      User.update_with_omniauth(@identity.user_id, @identity.name)
      if @identity.discord?
        Identity.update_connections(auth.credentials.token, @current_user.id)
      end

      if param['seat'].present?
        result = User.update_seat_from_omniauth(@identity.user_id, param['seat'])
        flash[result[:success] ? :success : :danger] = result[:message]
        if result[:success]
          Identity.update_qconbyoc(current_user.seat_id)
        end
      elsif current_user.seat.present?
        Identity.update_qconbyoc(current_user.seat_id, true)
      end
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
