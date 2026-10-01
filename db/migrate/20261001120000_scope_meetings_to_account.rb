# frozen_string_literal: true

class ScopeMeetingsToAccount < ActiveRecord::Migration[7.1]
  include AccountIdMigrationHelper

  def up
    add_account_ownership(:ma_meetings)
  end

  def down
    remove_account_ownership(:ma_meetings)
  end
end
