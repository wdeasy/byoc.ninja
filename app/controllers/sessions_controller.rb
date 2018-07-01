class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => :create

  def login
  end

  def create
    auth = request.env['omniauth.auth']
    temp = { :name => auth.info['nickname'],
    				:avatar => auth.extra['raw_info']['avatar'],
                    :url => auth.extra['raw_info']['profileurl'],
                    :uid => auth.uid }
    user = User.where(steamid: temp[:uid]).first_or_create
    user.update_attributes(
   	  :name	=> temp[:name],
  	  :url 	=> temp[:url],
  	  :avatar 		=> temp[:avatar]
  	)
    if user
  	  log_in user
      redirect_to root_url
    else
      flash.now[:danger] = 'Failed to create session.'
      redirect_to root_url
    end
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
