class Show < ApplicationRecord
  has_many :seasons, dependent: :destroy

  TV_SHOW_ROOT_DIR = '/media/tv/'

  def self.rescan_shows
    Pathname.new(TV_SHOW_ROOT_DIR).each_child do |child|
      # Only scan non-hidden directories
      if child.directory? && child.basename.to_s[0] != '.'
        show = Show.find_or_create_by(base_dir: child.realdirpath.to_s) do |show|
          show.title = child.basename.to_s
        end
        RescanShowJob.perform_later show.id
      end
    end
  end

  def rescan_seasons
    Pathname.new(self.base_dir).each_child do |season_directory|
      # Only scan non-hidden directories
      if season_directory.directory? && season_directory.basename.to_s[0] != '.'
        season = Season.find_or_create_by(base_dir: season_directory.realdirpath.to_s, show: self) do |season|
          season.label = season_directory.basename.to_s
        end
        RescanSeasonJob.perform_later season.id
      end
    end
  end
end
