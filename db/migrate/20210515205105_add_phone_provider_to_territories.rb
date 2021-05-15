# frozen_string_literal: true

class AddPhoneProviderToTerritories < ActiveRecord::Migration[6.1]
  def change
    add_reference :territories, :phone_provider, null: true, foreign_key: true
  end
end
