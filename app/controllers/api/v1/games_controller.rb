module Api
  module V1
    class GamesController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :restrict_access
      before_action :admin_api_user, :except => [:index]

      def index
        @games = Game.all.order("name ASC")
        render :json => @games
      end

      def update
        @game = Game.find_by_appid(params[:id])
        if @game.update_attributes(game_params)
          render :json => @game
        else
          render :json => {:error => "unable to update game"}
        end
      end

      private
      def restrict_access
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end

      def game_params
        params.require(:game).permit(:name, :link, :image)
      end

      def admin_api_user
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.find_by(access_token: token).user.admin?
        end
      end
    end
  end
end
