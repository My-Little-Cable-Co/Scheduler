class CreateShows < ActiveRecord::Migration[6.1]
  def change
    create_table :shows do |t|
      t.string :title
      t.string :base_dir

      t.timestamps
    end
    add_index :shows, :title, unique: true
  end
end
