class CreateAirings < ActiveRecord::Migration[6.1]
  def change
    create_table :airings do |t|
      t.references :show, null: false, foreign_key: true
      t.references :channel, null: false, foreign_key: true
      t.text :recurrence

      t.timestamps
    end
  end
end
