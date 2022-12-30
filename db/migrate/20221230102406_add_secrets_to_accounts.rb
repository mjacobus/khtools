# frozen_string_literal: true

class AddSecretsToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :secrets, :jsonb
  end
end
