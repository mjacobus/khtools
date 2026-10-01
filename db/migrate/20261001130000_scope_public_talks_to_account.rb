# frozen_string_literal: true

class ScopePublicTalksToAccount < ActiveRecord::Migration[7.1]
  include AccountIdMigrationHelper

  def up
    add_account_ownership(:congregations)
    add_account_ownership(:public_speakers)
    add_account_ownership(:public_talks)
  end

  def down
    remove_account_ownership(:public_talks)
    remove_account_ownership(:public_speakers)
    remove_account_ownership(:congregations)
  end
end
