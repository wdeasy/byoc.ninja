module Api
  module V1
    class HostsController < ApplicationController
      before_action :restrict_access

      def index
        @hosts = Host.includes(:game, :users, :seats).where(visible: true).where("games.joinable = true").order("games.name ASC, users_count DESC, hosts.current IS NULL, hosts.current DESC, hosts.name DESC")
        render :json => @hosts
      end

      private
      def restrict_access
        authenticate_or_request_with_http_token do |token, options|
          ApiKey.exists?(access_token: token)
        end
      end
    end
  end
end
