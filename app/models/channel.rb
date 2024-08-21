class Channel < ApplicationRecord
  validates :number, uniqueness: true, presence: true
  validates :short_name, length: { maximum: 5 }, uniqueness: true, presence: true
  validates :long_name, uniqueness: true, presence: true

  has_many :airings, dependent: :destroy
  has_many :listings

  def listings_for_date(airdate)
    # Calculated listings are the "final" listings that take into account
    # precedence rules. We should end up with at most 1 listing per timeslot.
    calculated_listings = []
    listings_by_timeslot = listings.where(airdate: airdate).group_by(&:timeslot)
    listings_by_timeslot.sort_by{|timeslot, listings| timeslot }.each do |timeslot, listings|
      # Since we created this data structure from database records, we know
      # that any timeslots that appear here have at least one listing. The key
      # would not exist if there were zero listings for that timeslot.

      # Scenario 1: All listings for this timeslot start at this timeslot.
      # In this case, we can simply ask the class to let us know which one
      # is the most specific.
      if listings.all?{|l| l.parent_listing_id.nil? }
        calculated_listings << Listing.most_specific_listing(listings)

      # Scenario 2: All listings for this timeslot started before this
      # timeslot.
      elsif listings.all?{|l| l.parent_listing_id.present? }
        # If all the listings are continuations, it must be continuing the
        # previous timeslot.
        timeslot_are_attempting_to_fill = Airing::TIMESLOTS.find_index(timeslot)
        # If the timeslot we are trying to fill is the first timeslot, we'll
        # have to look at the last timeslot from yesterday.
        if timeslot_are_attempting_to_fill == 0
          yesterdays_last_listing = listings_for_date(airdate - 1.day).select{|l| l.timeslot == Airing::TIMESLOTS[-1]}[0]
          previous_listing = yesterdays_last_listing
        
        # Since we process timeslots in order, and we're not attempting to
        # fill the first timeslot of the day, we have already calculated the
        # previous listing, and it is in the last position of the array.
        else
          previous_listing = calculated_listings[-1]
        end
        
        # Now that we have the previous listing, it's simply a matter of
        # picking the listing with a parent_listing_id of either the
        # previous listing's id or the previous listings's
        # parent_listing_id. Anything else would be "continuing" something
        # that never started.
        calculated_listings << listings.select{|l| l.parent_listing_id == previous_listing&.id || l.parent_listing_id == previous_listing&.parent_listing_id}[0]

      # Scenario 3: Some listings start before this timeslot, some start at
      # this timeslot.
      else
        # We should give precedence to continuations. If something is
        # already in progress, we should let it finish. If one of the
        # continuations is of something that is airing, we'll pick it.

        # Find the previous listing
        timeslot_are_attempting_to_fill = Airing::TIMESLOTS.find_index(timeslot)
        if timeslot_are_attempting_to_fill == 0
          yesterdays_last_listing = listings_for_date(airdate - 1.day).select{|l| l.timeslot == Airing::TIMESLOTS[-1]}[0]
          previous_listing = yesterdays_last_listing
        else
          previous_listing = calculated_listings[-1]
        end

        continuation_listings = listings.select{|l| l.parent_listing_id.present?}
        chosen_listing = continuation_listings.select{|l| l.parent_listing_id == previous_listing&.id || l.parent_listing_id == previous_listing&.parent_listing_id}[0]
        if chosen_listing
          calculated_listings << chosen_listing

        # If none of the continuations were airing in the previous timeslot,
        # then we'll just pick the most specific of the listings that is
        # newly starting in this timeslot.
        else
          newly_starting_listings = listings.select{|l| l.parent_listing_id.nil?}
          calculated_listings << Listing.most_specific_listing(newly_starting_listings)
        end
      end
    end

    # We may have selected "nil" as some of the listings. We'll return
    # calculated_listings with any "nil"s stripped out.
    calculated_listings.compact
  end
end
