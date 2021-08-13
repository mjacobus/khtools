# frozen_string_literal: true

class CreateDbTerritoryAssignments < ActiveRecord::Migration[6.1]
  def change
    create_table :territory_assignments do |t|
      t.references :territory, null: false, foreign_key: true
      t.references :assignee, null: false, foreign_key: { to_table: :publishers }
      t.datetime :assigned_at, null: false
      t.datetime :returned_at, null: true

      t.timestamps
    end
  end
end
