class Schedule
  def self.for(first_day, last_day)

    schedule = {
      channels: []
    }

    # TODO: Opportunity for optimization, as this performs 3 queries per
    # channel.
    Channel.order(:number).each do |channel|
      listings = Listing.where(channel: channel, airdate: first_day..last_day).includes(:airing, :show).order(:airdate, :timeslot).group_by{|listing| Time.zone.parse("#{listing.airdate} #{listing.timeslot}")}
      channel_entry = {
        number: channel.number,
        short_name: channel.short_name,
        lineup: listings.map do |airtime, potentially_overlapped_listings|
          listing = potentially_overlapped_listings.sort_by(&:specificity_score)[-1]
          # we only want listings that represent the start of an airing, not
          # the continuation ones that fill a timeslot
          if(listing.parent_listing_id.nil?)
            start_time = airtime
            end_time = (airtime + listing.airing.usual_block_length_in_minutes.minutes)

            if start_time >= Time.zone.now
              # if it hasn't started yet, it's all remaining and none elapsed
              minutes_elapsed = 0
              minutes_remaining = listing.airing.usual_block_length_in_minutes
            elsif end_time <= Time.zone.now
              # if it has ended, there is nothing left, and all elapsed
              minutes_elapsed = listing.airing.usual_block_length_in_minutes
              minutes_remaining = 0
            else
              # we are in between when it started and when it ends (it's on now!), so
              # it's (end_time - now) remaining and (now - start time) elapsed
              minutes_elapsed = ((Time.zone.now - start_time) / 60).to_i
              minutes_remaining = ((end_time - Time.zone.now) / 60).to_i
            end
            {
              title: listing.show.title,
              start_time: start_time,
              end_time: end_time,
              all_day: listing.airing.usual_block_length_in_minutes.minutes == (24 * 60 * 60) && airtime.to_s.include?('T00:00:00'),
              minutes_elapsed: minutes_elapsed,
              minutes_remaining: minutes_remaining,
              category: 'regular' # reserved for future use
            }
          else
            nil
          end
        end.compact,
      }
      # After creating the channel's lineup, look for empty timeslots and
      # insert a TBD airing as needed.
      Airing::TIMESLOTS.each do |timeslot|
        timeslot_as_time = Time.zone.parse(timeslot)
        timeslot_is_filled = channel_entry[:lineup].any? do |listing|
          timeslot_as_time.between?(listing[:start_time], listing[:end_time] - 1.second)
        end

        unless timeslot_is_filled
          time_in_past = timeslot_as_time < Time.zone.now
          filler_airing = {
              title: "To be announced",
              start_time: timeslot_as_time,
              end_time: timeslot_as_time + 30.minutes,
              all_day: false,
              minutes_elapsed: time_in_past ? [30, ((timeslot_as_time - Time.zone.now) / 60).round.abs].min : 0,
              minutes_remaining: 30 - [30, (time_in_past ? ((timeslot_as_time - Time.zone.now) / 60).round.abs : 0)].min,
              category: 'regular' # reserved for future use
          }
          channel_entry[:lineup] << filler_airing
        end
      end
      channel_entry[:lineup].sort!{|a, b| a[:start_time] <=> b[:start_time]}
      schedule[:channels] << channel_entry
    end

    schedule
  end
end
