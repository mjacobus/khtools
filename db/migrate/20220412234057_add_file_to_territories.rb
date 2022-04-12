# frozen_string_literal: true

class AddFileToTerritories < ActiveRecord::Migration[6.1]
  def change
    add_column :territories, :file, :string
  end
end
