# frozen_string_literal: true

class AddMapCoordinatesToTerritories < ActiveRecord::Migration[6.1]
  def change
    add_column :territories, :map_coordinates, :json
  end
end
