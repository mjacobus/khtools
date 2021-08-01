# frozen_string_literal: true

class AddPendingVerificationToTerritories < ActiveRecord::Migration[6.1]
  def change
    add_column :territories, :pending_verification, :boolean, default: false
  end
end
