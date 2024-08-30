class ChannelsController < ApplicationController
  before_action :set_channel, only: [:show, :edit, :update, :destroy, :schedule]

  # GET /channels
  # GET /channels.json
  def index
    @channels = Channel.all
  end

  # GET /channels/1
  # GET /channels/1.json
  def show
    start_date = Date.parse(params.fetch(:start_date, Date.today.beginning_of_week.strftime('%F')))
    end_date = start_date + 6.days
    @days = (start_date..end_date).to_a
    @listings = {}
    @days.each do |day|
      @listings[day] = @channel.listings_for_date(day)
    end
  end

  # GET /channels/new
  def new
    @channel = Channel.new
  end

  # GET /channels/1/edit
  def edit
  end

  # POST /channels
  # POST /channels.json
  def create
    @channel = Channel.new(channel_params)

    respond_to do |format|
      if @channel.save
        format.html { redirect_to @channel, notice: 'Channel was successfully created.' }
        format.json { render :show, status: :created, location: @channel }
      else
        format.html { render :new }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /channels/1
  # PATCH/PUT /channels/1.json
  def update
    respond_to do |format|
      if @channel.update(channel_params)
        format.html { redirect_to @channel, notice: 'Channel was successfully updated.' }
        format.json { render :show, status: :ok, location: @channel }
      else
        format.html { render :edit }
        format.json { render json: @channel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /channels/1
  # DELETE /channels/1.json
  def destroy
    @channel.destroy
    respond_to do |format|
      format.html { redirect_to channels_url, notice: 'Channel was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /channels/ch7/schedule.json
  def schedule
    respond_to do |format|
      format.json {
        render json: Schedule.for_channel(@channel, Time.zone.now.to_date, Time.zone.now.to_date)
      }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_channel
      # /channels/ch7 -> look up by channel number
      # /channels/7   -> look up by id
      if params[:id].downcase.starts_with?('ch')
        channel_number = params[:id].delete("^0-9")
        @channel = Channel.find_by_number!(channel_number)
      else
        @channel = Channel.find(params[:id])
      end
    end

    # Only allow a list of trusted parameters through.
    def channel_params
      params.require(:channel).permit(:number, :short_name, :long_name)
    end
end
