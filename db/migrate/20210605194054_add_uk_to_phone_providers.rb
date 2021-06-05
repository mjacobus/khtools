# frozen_string_literal: true

class AddUkToPhoneProviders < ActiveRecord::Migration[6.1]
  def change
    add_index(:phone_providers, %i[name], unique: true)
  end
end
