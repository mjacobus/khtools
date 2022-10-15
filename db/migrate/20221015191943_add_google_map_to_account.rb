# frozen_string_literal: true

class AddGoogleMapToAccount < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :territory_map, :string
  end
end
