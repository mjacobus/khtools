# frozen_string_literal: true

class AddIndexToTerritoryNames < ActiveRecord::Migration[6.1]
  def change
    add_index :territories, :name
  end
end
