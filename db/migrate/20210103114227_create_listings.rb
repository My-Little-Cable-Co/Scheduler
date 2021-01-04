class CreateListings < ActiveRecord::Migration[6.1]
  def change
    create_table :listings do |t|
      t.references :channel, null: false, foreign_key: true
      t.date :airdate, null: false
      t.text :timeslot, null: false
      t.references :show, null: false, foreign_key: true
      t.references :airing, foreign_key: true
      t.integer :specificity_score, null: false, default: 0
      t.timestamps
    end
  end
end
