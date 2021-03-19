class AdminRide::RideCancellationsController < ApplicationController
  before_action :authenticate_user!
  before_action do
    Thread.current[:active_user] = current_user
  end


  def review
    begin
      @ride = Ride.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.now[:alert] = "Record not found."
      redirect_to admin_ride_index_path
      return
    end
  end

  def cancel
    begin
      @ride = Ride.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash.now[:alert] = "Record not found."
      redirect_to admin_ride_index_path
      return
    end

    if ride_params[:cancellation_reason] == 'Other'
      @cancellation_reason = ride_params[:cancellation_other_reason]
    else
      @cancellation_reason = ride_params[:cancellation_reason]
    end

    if %w[pending approved scheduled].include? @ride.status
      @ride.update_attributes(status: 'canceled', cancellation_reason: @cancellation_reason)
      @ride.token&.update_attribute(:ride_id, nil)
      flash.notice = 'Ride canceled.'
      redirect_to admin_ride_path @ride
    end
  end

  private
    def ride_params
      params.require(:ride).permit(:cancellation_reason, :cancellation_other_reason)
    end
end
