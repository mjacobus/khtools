# frozen_string_literal: true

class AddConfigToTerritories < ActiveRecord::Migration[7.0]
  def change
    add_column :territories, :config, :jsonb
  end
end
