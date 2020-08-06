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
        if @seat.present?
          render :json => @seat
        else
          render :json => 'invalid seat'
        end          
      end

      def taken
        @seat = Seat.where(seat: params[:seat])
        if @seat.present?
          @user = User.where(seat_id: @seat.id).first
          if @user.nil?
            render :json => false
          else
            render :json => true
          end
        else
          render :json => 'invalid seat'
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
