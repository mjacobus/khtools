# frozen_string_literal: true

class AddLatLonToTerritories < ActiveRecord::Migration[7.1]
  def change
    add_column :territories, :latitude, :decimal, precision: 9, scale: 6
    add_column :territories, :longitude, :decimal, precision: 9, scale: 6
  end
end
