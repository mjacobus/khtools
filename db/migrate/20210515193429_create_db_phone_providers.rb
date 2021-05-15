# frozen_string_literal: true

class CreateDbPhoneProviders < ActiveRecord::Migration[6.1]
  def change
    create_table :phone_providers do |t|
      t.string :name, unique: true

      t.timestamps
    end
  end
end
