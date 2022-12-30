# frozen_string_literal: true

class AddKmlMapToTerritories < ActiveRecord::Migration[7.0]
  def change
    add_column :territories, :kml, :text
  end
end
