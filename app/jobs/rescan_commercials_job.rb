class RescanCommercialsJob < ApplicationJob
  queue_as :default

  COMMERCIAL_ROOT_DIR = '/media/commercials/'

  def perform
    scan_commercial_directory(COMMERCIAL_ROOT_DIR)
  end

  def scan_commercial_directory(directory)
    Pathname.new(directory).each_child do |child|
      if child.directory?
        # Only scan non-hidden directories
        if child.basename.to_s[0] != '.'
          scan_commercial_directory(child)
        end
      elsif MediaConstants::VIDEO_FILE_EXTENSIONS.include?(child.extname.downcase)
        Commercial.find_or_create_by(file_path: child.realdirpath.to_s) do |commercial|
          commercial.title = child.basename(child.extname).to_s
        end
      end
    end
  end
end
