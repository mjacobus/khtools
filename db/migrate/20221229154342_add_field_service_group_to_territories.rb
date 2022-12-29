# frozen_string_literal: true

class AddFieldServiceGroupToTerritories < ActiveRecord::Migration[6.1]
  def change
    add_reference :territories, :field_service_group, null: true, foreign_key: true
  end
end
