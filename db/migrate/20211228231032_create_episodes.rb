class CreateEpisodes < ActiveRecord::Migration[6.1]
  def change
    create_table :episodes do |t|
      t.references :show, null: false, foreign_key: true
      t.references :season, null: false, foreign_key: true
      t.string :name
      t.integer :number
      t.string :filepath

      t.timestamps
    end
  end
end
