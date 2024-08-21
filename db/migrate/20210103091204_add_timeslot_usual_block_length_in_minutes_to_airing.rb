class AddTimeslotUsualBlockLengthInMinutesToAiring < ActiveRecord::Migration[6.1]
  def change
    add_column :airings, :timeslot, :string, null: false
    add_column :airings, :usual_block_length_in_minutes, :integer
  end
end
