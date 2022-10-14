# frozen_string_literal: true

class ScopePublishersToAccount < ActiveRecord::Migration[6.1]
  include AccountIdMigrationHelper

  def up
    add_account_ownership(:publishers)
    add_account_ownership(:field_service_groups)

    remove_index(:field_service_groups, %i[name], unique: true)
    add_index(:field_service_groups, %i[account_id name], unique: true)
  end

  def down
    remove_index(:field_service_groups, %i[account_id name], unique: true)
    add_index(:field_service_groups, %i[name], unique: true)

    remove_account_ownership(:publishers)
    remove_account_ownership(:field_service_groups)
  end
end
