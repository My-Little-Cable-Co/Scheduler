class RescanSeasonJob < ApplicationJob
  queue_as :default

  def perform(season_id)
    season = Season.where(id: season_id).first
    return unless season
    season.rescan_episodes
  end
end
