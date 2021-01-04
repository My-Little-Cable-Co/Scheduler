class Airing < ApplicationRecord
  belongs_to :show
  belongs_to :channel
  has_many :listings, dependent: :destroy

  serialize :recurrence, Montrose::Recurrence

  TIMESLOTS = [
    '00:00', '00:30',
    '01:00', '01:30',
    '02:00', '02:30',
    '03:00', '03:30',
    '04:00', '04:30',
    '05:00', '05:30',
    '06:00', '06:30',
    '07:00', '07:30',
    '08:00', '08:30',
    '09:00', '09:30',
    '10:00', '10:30',
    '11:00', '11:30',
    '12:00', '12:30',
    '13:00', '13:30',
    '14:00', '14:30',
    '15:00', '15:30',
    '16:00', '16:30',
    '17:00', '17:30',
    '18:00', '18:30',
    '19:00', '19:30',
    '20:00', '20:30',
    '21:00', '21:30',
    '22:00', '22:30',
    '23:00', '23:30',
  ]

  BLOCK_LENGTHS = [
    30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330, 360, 390, 420, 450, 480,
    510, 540, 570, 600, 630, 660, 690, 720, 750, 780, 810, 840, 870, 900, 930,
    960, 990, 1020, 1050, 1080, 1110, 1140, 1170, 1200, 1230, 1260, 1290, 1320,
    1350, 1380, 1410, 1440
  ]

  validates :timeslot, presence: true, inclusion: { in: Airing::TIMESLOTS, message: 'Timeslot must be on a half-hour mark.' }

  after_commit :create_listings, on: :create

  def summary
    if recurrence
      recurrence_info = recurrence.to_h
      "#{usual_block_length_in_minutes} minutes every #{recurrence_info[:on].map(&:titleize).to_sentence} starting at #{timeslot} between #{recurrence_info.fetch(:starts, Date.new(1900,1,1)).strftime('%F')} and #{recurrence_info.fetch(:until, Date.new(2100,12,31)).strftime('%F')}"
    else
      "No recurrence data"
    end
  end

  # You can make multiple airing records that yield overlapping events. We use
  # the number of days between the start of the recurrence and the end as a
  # proxy for how "specific" the airing is. This may turn out to be naive, but
  # I figure that very broad time ranges will be more generic listings and
  # very short ranges will be more specific. I am also assuming that the more
  # specific records should take precedence. The result is multiplied by
  # negative one so that more generic means a "less" specific score.
  def specificity_score
    recurrence_info = recurrence.to_h
    start_date = recurrence_info.fetch(:starts, Date.new(1900,1,1)).to_date
    end_date = recurrence_info.fetch(:ends, Date.new(2100,12,31)).to_date
    [(end_date - start_date).to_i, 0].max * -1
  end

  def create_listings
    # Create a year in advance
    ActiveRecord::Base.transaction do
      Listing.where(airing_id: id, channel_id: channel_id, show_id: show_id).where('airdate >= ?', Date.today).delete_all
      recurrence.events.each do |event|
        break if event > (Date.today + 1.year)
        listing = Listing.where(channel_id: channel_id,
                                airdate: event.to_date,
                                timeslot: timeslot,
                                show_id: show_id,
                                airing_id: id,
                                specificity_score: specificity_score).create
        if self.usual_block_length_in_minutes > 30
          # Find the index of the timeslot that is being used. This requires
          # the TIMESLOTS array constant be ordered.
          index_of_initial_timeslot = Airing::TIMESLOTS.find_index(timeslot)
          # Find out the number of additional 30 minute blocks that are
          # required for the the length of the airing.
          additional_timeslots_needed = (self.usual_block_length_in_minutes / 30) - 1
          # We will build the additional listings, store them in this list,
          # then insert them into the database as a batch.
          continuation_listings = []
          # If we need 3 additional, this loop will run with i equalling 1, 2,
          # and 3.
          1.upto(additional_timeslots_needed) do |i|
            # The correct timeslot is the element i spaces after the initial
            # one. If "09:00" is index 18, then "09:30" is index 19, "10:00"
            # is index 20, and so on.
            next_timeslot_index = index_of_initial_timeslot + i
            # If the computed index is out of bounds, subtract the length of
            # all timeslots. This has the effect of "wrapping around". Think:
            # we don't want 24:30 (a nonexistent index 49), we want 00:30,
            # which is index 1. 49 minus the number of elements in TIMESLOTS
            # (48) is 1.
            #
            # We also note that we should increment the airdate accordingly.
            if next_timeslot_index > (Airing::TIMESLOTS.length - 1)
              next_timeslot_index -= Airing::TIMESLOTS.length 
              pushed_into_following_day = true
            end

            # This is the timeslot we should make a continuation listing for.
            # Continuation listings are listings that have the id of the
            # parent listing stored as their "parent_listing_id". This column
            # being set is our sign that the show did not begin at this
            # timeslot, but rather at the timeslot of its parent. Having
            # listing records for each 30 minute timeslot allows us to easily
            # know what is on without having to look in the past.
            continuation_timeslot = Airing::TIMESLOTS[next_timeslot_index]

            continuation_listings << Listing.new(channel_id: channel_id,
                                                 airdate: pushed_into_following_day ? event.to_date + 1.day : event.to_date,
                                                 timeslot: continuation_timeslot,
                                                 show_id: show_id,
                                                 airing_id: id,
                                                 specificity_score: specificity_score,
                                                 parent_listing_id: listing.id)

          end
          Listing.import! continuation_listings
        end
      end
    end
  end
end
