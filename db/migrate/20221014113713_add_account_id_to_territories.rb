# frozen_string_literal: true

class AddAccountIdToTerritories < ActiveRecord::Migration[6.1]
  include AccountIdMigrationHelper

  def up
    add_account_ownership(:territories)

    remove_index(:territories, %i[name type], unique: true)
    add_index(:territories, %i[account_id name type], unique: true)
  end

  def down
    remove_index(:territories, %i[account_id name type], unique: true)
    add_index(:territories, %i[name type], unique: true)

    remove_account_ownership(:territories)
  end
end
