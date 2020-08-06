module Api
  module V1
    class SeatsController < ApplicationController
      before_action :restrict_access

      def index
        @seats = Seat.active.order(:sort).uniq

        render :json => @seats
      end

      def info
        @seat = Seat.where(seat: params[:seat])

        render :json => @seat
      end

      def taken
        @seat = Seat.where(seat: params[:seat]).first
        if @seat.nil?
          render :json => false
        else
          render :json => true
        end
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
