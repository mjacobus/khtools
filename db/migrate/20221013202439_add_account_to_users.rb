# frozen_string_literal: true

class AddAccountToUsers < ActiveRecord::Migration[6.1]
  include AccountIdMigrationHelper

  def up
    add_account_ownership(:users, required: false)
  end

  def down
    remove_account_ownership(:users, required: false)
  end
end
