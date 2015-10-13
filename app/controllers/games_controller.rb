class GamesController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
  	@games = Game.order("gameextrainfo ASC")
  end

  def edit
  	@game = Game.find_by_gameid(params[:gameid])
  end

  def update
  	@game = Game.find_by_gameid(params[:gameid])
    if @game.update_attributes(game_params)
      flash[:success] = "Game updated."
      redirect_to games_url
    else
      render 'edit'
    end
  end

  private
    def game_params
      params.require(:game).permit(:gameextrainfo, :protocol)
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