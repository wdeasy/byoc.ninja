module SessionsHelper

  # Logs in the given user.
  def log_in(user)
    session[:steamid] = user.steamid
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    if (steamid = session[:steamid])
      @current_user ||= User.find_by(steamid: steamid)
    end
  end

  def current_user?(user)
    user == current_user
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end 

  # Logs out the current user.
  def log_out
    session.delete(:steamid)
    @current_user = nil
  end

  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end 
end
