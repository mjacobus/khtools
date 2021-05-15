# frozen_string_literal: true

class AddPhoneNumbersToTerritories < ActiveRecord::Migration[6.1]
  def change
    add_column :territories, :initial_phone_number, :integer, limit: 8
    add_column :territories, :final_phone_number, :integer, limit: 8
  end
end
