module Api
  module V1
    class HostsController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :restrict_access
      before_action :admin_api_user, :except => [:index]

      def index
        @hosts = Host.includes(:game, :users, :seats).where(visible: true).where("games.joinable = true").order("games.name ASC, users_count DESC, hosts.current IS NULL, hosts.current DESC, hosts.name DESC")
        render :json => @hosts
      end

      def update
        @host = Host.find_by_id(params[:id])
        if @host.update_attributes(host_params)
          render :json => @host
        end
      end

      private
      def restrict_access
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end

      def host_params
        params.require(:host).permit(:name, :map, :current, :max, :password, :last_successful_query)
      end

      def admin_api_user
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.find_by(access_token: token).user.admin?
        end
      end
    end
  end
end
