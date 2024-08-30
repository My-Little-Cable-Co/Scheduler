class Commercial < ApplicationRecord
  before_save :update_duration

  private

  def update_duration
    if file_path and File.exist?(file_path)
      begin
        ffprobe_output, _stderr, status = Open3.capture3('ffprobe', '-print_format', 'json', '-show_streams', file_path)
        if status.success?
          video_info = JSON.parse(ffprobe_output)
          video_streams = video_info["streams"].select{|stream| stream["codec_type"] == "video"}
          if video_streams.any?
            self.duration = video_streams.first["duration"]
          end
        end
      rescue StandardError
        return
      end
    end
  end
end
