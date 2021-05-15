# frozen_string_literal: true

class CreateTerritories < ActiveRecord::Migration[6.1]
  def change
    create_table :territories do |t|
      t.string :name, unique: true
      t.datetime :assigned_at
      t.datetime :returned_at
      t.string :type

      t.timestamps
    end

    add_reference :territories, :assignee, foreign_key: { to_table: :publishers }
  end
end
