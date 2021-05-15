# frozen_string_literal: true

class AddIndexToTerritories < ActiveRecord::Migration[6.1]
  def change
    add_index :territories, :type
  end
end
