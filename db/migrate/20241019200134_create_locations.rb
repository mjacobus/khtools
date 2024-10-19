class CreateLocations < ActiveRecord::Migration[7.1]
  def change
    create_table :locations do |t|
      t.string :address
      t.string :street_name
      t.string :number
      t.decimal :latitude, precision: 9, scale: 6
      t.decimal :longitude, precision: 9, scale: 6
      t.string :block_number
      t.references :territory, null: false, foreign_key: true
      t.datetime :last_contacted_at

      t.timestamps
    end
  end
end
