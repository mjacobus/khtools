# frozen_string_literal: true

class AddNotesToTerritoryAssignments < ActiveRecord::Migration[6.1]
  def change
    add_column :territory_assignments, :notes, :text
  end
end
