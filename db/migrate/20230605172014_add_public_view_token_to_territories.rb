# frozen_string_literal: true

class AddPublicViewTokenToTerritories < ActiveRecord::Migration[7.0]
  def change
    add_column :territories, :public_view_token, :string
    add_index :territories, :public_view_token, unique: true
    add_column :territories, :public_view_token_expires_at, :datetime
  end
end
