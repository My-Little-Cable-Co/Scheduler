class SeasonsController < ApplicationController
  before_action :set_show
  before_action :set_season, only: [:show, :edit, :update, :destroy]

  # GET /shows/{:show_id}/seasons
  # GET /shows/{:show_id}/seasons.json
  def index
    @seasons = @show.seasons.all
  end

  # GET /shows/{:show_id}/seasons/1
  # GET /shows/{:show_id}/seasons/1.json
  def show
  end

  # GET /shows/{:show_id}/seasons/new
  def new
    @season = @show.seasons.new
  end

  # GET /shows/{:show_id}/seasons/1/edit
  def edit
  end

  # POST /shows/{:show_id}/seasons
  # POST /shows/{:show_id}/seasons.json
  def create
    @season = @show.seasons.new(season_params)

    respond_to do |format|
      if @season.save
        format.html { redirect_to show_seasons_path(@show, @season), notice: 'Season was successfully created.' }
        format.json { render :show, status: :created, location: @season }
      else
        format.html { render :new }
        format.json { render json: @season.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shows/{:show_id}/seasons/1
  # PATCH/PUT /shows/{:show_id}/seasons/1.json
  def update
    respond_to do |format|
      if @season.update(season_params)
        format.html { redirect_to @season, notice: 'Season was successfully updated.' }
        format.json { render :show, status: :ok, location: @season }
      else
        format.html { render :edit }
        format.json { render json: @season.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shows/{:show_id}/seasons/1
  # DELETE /shows/{:show_id}/seasons/1.json
  def destroy
    @season.destroy
    respond_to do |format|
      format.html { redirect_to show_seasons_url(@show), notice: 'Season was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

    def set_show
      @show = Show.find(params[:show_id])
    end

    def set_season
      @season = @show.seasons.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def season_params
      params.require(:season).permit(:show_id, :label, :base_dir)
    end
end
