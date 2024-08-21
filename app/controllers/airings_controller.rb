class AiringsController < ApplicationController
  before_action :set_airing, only: [:show, :edit, :update, :destroy]

  # GET /airings/1
  # GET /airings/1.json
  def show
  end

  # GET /airings/new
  def new
    @airing = Airing.new(channel_id: params[:channel_id])
  end

  # POST /airings
  # POST /airings.json
  def create
    recurrence_rule_params = params.fetch('airing', {}).delete('recurrence_rules')

    @airing = Airing.new(airing_params)

    if recurrence_rule_params
      days_of_week = recurrence_rule_params.fetch('day_of_week', []).map(&:to_sym)
      recurrence_rule = Montrose.weekly(on: days_of_week)
      start_date = recurrence_rule_params.fetch('starting', Date.new(1900,1,1))
      end_date = recurrence_rule_params.fetch('ending', Date.new(2100,12,31))
      recurrence_rule = recurrence_rule.between(start_date..end_date)
      recurrence_rule = recurrence_rule.at(@airing.timeslot)
      @airing.recurrence = recurrence_rule

      begin
        # Try it out, make sure it works.
        @airing.recurrence.events.take(1)
      rescue Montrose::ConfigurationError => error
        @airing.errors.add(:recurrence, 'Not enough information to create recurrence rule.')
      end
    else
      @airing.errors.add(:recurrence, 'information not given.')
    end

    respond_to do |format|
      if @airing.errors.empty? && @airing.save
        format.html { redirect_to @airing.channel, notice: 'Airing was successfully created.' }
        format.json { render :show, status: :created, location: @airing }
      else
        format.html { render :new }
        format.json { render json: @airing.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /airings/1
  # DELETE /airings/1.json
  def destroy
    @airing.destroy
    respond_to do |format|
      format.html { redirect_to @airing.channel, notice: 'Airing was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_airing
      @airing = Airing.where(channel_id: params[:channel_id]).find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def airing_params
      params.require(:airing).permit(:show_id, :channel_id, :timeslot, :usual_block_length_in_minutes)
    end
end
