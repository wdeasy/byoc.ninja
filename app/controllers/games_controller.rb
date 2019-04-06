class GamesController < ApplicationController
  before_action :logged_in_user, :except => [:index]
  before_action :admin_user, :except => [:index]

  def index
  	@games = Game.where(:source => 'auto', :supported => true).order("name ASC")
    @games = Game.where(:source => 'manual').order("name ASC") if params[:manual].present?
    @games = Game.all.order("name ASC") if params[:all].present?
  end

  def edit
  	@game = Game.find(params[:id])
  end

  def update
  	@game = Game.find(params[:id])
    if @game.update_attributes(game_params)
      flash[:success] = "Game updated."
      redirect_to games_url
    else
      render 'edit'
    end
  end

  def new
    @game = Game.new
  end

  def create
    @game = Game.new(add_params)
    @game.source = 'manual'

    if @game.save
      flash[:success] = "Game added."
      redirect_to games_url
    else
      render 'new'
    end
  end

  def destroy
    Game.find_by_id(params[:id]).destroy
    flash[:success] = "Game deleted"
    redirect_to games_url
  end

  private
    def add_params
      params.require(:game).permit(:appid, :name, :link, :source, :supported)
    end

    def game_params
      params.require(:game).permit(:name, :joinable, :supported)
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
