# frozen_string_literal: true

class AddUkToFieldServiceGroups < ActiveRecord::Migration[6.1]
  def change
    add_index(:field_service_groups, %i[name], unique: true)
  end
end
