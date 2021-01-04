class AddParentListingToListings < ActiveRecord::Migration[6.1]
  def change
    add_reference :listings, :parent_listing, foreign_key: { to_table: :listings }
  end
end
