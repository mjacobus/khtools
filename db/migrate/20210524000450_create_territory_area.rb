# frozen_string_literal: true

class CreateTerritoryArea < ActiveRecord::Migration[6.1]
  def change
    create_table :territory_areas do |t|
      t.string :name, unique: true
      t.string :type

      t.timestamps
    end
  end
end
