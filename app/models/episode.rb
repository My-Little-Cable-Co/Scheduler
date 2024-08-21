class Episode < ApplicationRecord
  belongs_to :show
  belongs_to :season

  EPISODE_NUMBER_CAPTURE_REGEX = /(?:[eE])(?<first_episode_number>\d+)(-(?:[eE])?(?<second_episode_number>\d+))?.*/

  def self.parse_episode_number_from_filepath(filepath)
    matchdata = EPISODE_NUMBER_CAPTURE_REGEX.match(filepath)
    return nil unless matchdata
    return [
      matchdata.named_captures['first_episode_number'],
      matchdata.named_captures['second_episode_number']
    ].compact.join('-')
  end
end
