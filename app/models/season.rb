class Season < ApplicationRecord
  belongs_to :show
  has_many :episodes, dependent: :destroy

  def rescan_episodes
    Pathname.new(self.base_dir).each_child do |episode_path|
      if MediaConstants::VIDEO_FILE_EXTENSIONS.include?(episode_path.extname.downcase)
        Episode.find_or_create_by(filepath: episode_path.realdirpath.to_s, show: self.show, season: self) do |episode|
          episode.name = episode_path.basename.to_s
          episode.number = Episode.parse_episode_number_from_filepath(episode_path.basename.to_s)
        end
      end
    end
  end
end
