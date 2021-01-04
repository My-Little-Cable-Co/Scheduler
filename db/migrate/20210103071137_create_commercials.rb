class CreateCommercials < ActiveRecord::Migration[6.1]
  def change
    create_table :commercials do |t|
      t.string :title
      t.string :file_path

      t.timestamps
    end
    add_index :commercials, :title, unique: true
  end
end
