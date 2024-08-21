class CreateSeasons < ActiveRecord::Migration[6.1]
  def change
    create_table :seasons do |t|
      t.references :show, null: false, foreign_key: true
      t.string :label
      t.string :base_dir

      t.timestamps
    end
  end
end
