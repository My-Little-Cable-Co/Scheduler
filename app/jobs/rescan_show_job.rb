class RescanShowJob < ApplicationJob
  queue_as :default

  def perform(show_id)
    show = Show.where(id: show_id).first
    return unless show
    show.rescan_seasons
  end
end
