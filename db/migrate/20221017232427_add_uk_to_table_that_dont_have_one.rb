# frozen_string_literal: true

class AddUkToTableThatDontHaveOne < ActiveRecord::Migration[6.1]
  def change
    add_index :territory_areas, %i[name], unique: true
    add_index :intercom_types, %i[name], unique: true
  end
end
