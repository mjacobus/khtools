# frozen_string_literal: true

class CreateDbFieldServiceGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :field_service_groups do |t|
      t.string :name

      t.timestamps
    end
  end
end
