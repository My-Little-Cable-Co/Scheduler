class CreateChannels < ActiveRecord::Migration[6.1]
  def change
    create_table :channels do |t|
      t.integer :number, null: false, index: { unique: true }
      t.string :short_name, null: false, index: { unique: true }, limit: 5
      t.string :long_name, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
