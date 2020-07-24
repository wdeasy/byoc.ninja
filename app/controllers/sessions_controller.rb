class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => :create

  def login
  end

  def create
    auth = request.env['omniauth.auth']

    @identity = Identity.find_with_omniauth(auth)
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
        user = User.create_with_omniauth(auth)
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
      User.update_with_omniauth(@identity.user.id, auth)
    end

    if request.env['omniauth.params']['seat'].present?
      result = User.update_seat_from_omniauth(@identity.user_id, request.env['omniauth.params']['seat'])
      flash[result[:success] ? :success : :danger] = result[:message]
    end

    redirect_to root_url
  end

  def failure
  	flash.now[:danger] = 'Authentication Failure.'
  	redirect_to root_url
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

end
