# frozen_string_literal: true

class AddGoogleMapsMapToTerritories < ActiveRecord::Migration[6.1]
  def change
    add_column :territories, :google_map, :string
  end
end
