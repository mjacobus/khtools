# frozen_string_literal: true

class AddLastAssignmentToTerritories < ActiveRecord::Migration[7.0]
  def change
    add_reference :territories,
                  :last_assignment,
                  foreign_key: { to_table: :territory_assignments }
  end
end
