class AddDurationAndSubjectToCommercials < ActiveRecord::Migration[7.2]
  def change
    add_column :commercials, :duration, :decimal, precision: 6, scale: 2
    add_column :commercials, :subject, :string
  end
end
