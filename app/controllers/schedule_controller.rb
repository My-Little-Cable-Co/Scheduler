class ScheduleController < ApplicationController
  def index
    respond_to do |format|
      format.html { render layout: false }
      format.json { render json: Schedule.for(Time.zone.now.to_date, Time.zone.now.to_date) }
    end
  end
end

