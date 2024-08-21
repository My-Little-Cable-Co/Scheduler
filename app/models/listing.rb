class Listing < ApplicationRecord
  belongs_to :channel
  belongs_to :show
  belongs_to :airing
  belongs_to :parent_listing, optional: true

  def display
    if self.show
      "#{self.show.title}#{self.parent_listing_id ? ' (cont\'d)' : ''}"
    else
      "TBD"
    end
  end

  # Given multiple listings, this will choose the one with the greatest
  # specificity_score. If there is a tie, the one that was created the most
  # recently will be chosen.
  def self.most_specific_listing(listings)
    listings ||= []
    listings.sort do |a,b|
      # For this comparison, we prefer the one with the greater
      # specificity score, so it is b <=> a
      spec_score_comp = b.specificity_score <=> a.specificity_score
      if spec_score_comp == 0
        # This this tiebreaker comparison, we want the most recently
        # created one. For this we compare the ids, and want the one
        # with the larger id, so it is also b <=> a.
        b.id <=> a.id
      else
        spec_score_comp
      end
    end[0]
  end
end
