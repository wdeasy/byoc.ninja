module Api
  module V1
    class SeatsController < ApplicationController
      before_action :restrict_access

      def index
        @seats = Seat.joins(:seats_users, :users).joins("LEFT JOIN hosts ON hosts.id = users.host_id").order("seats.sort ASC").uniq
        render :json => @seats
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
