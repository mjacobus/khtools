# frozen_string_literal: true

# What a file is called in Drive when someone renamed it there, and where the daily sync of
# Drive changes left off.
class AddDriveSyncColumns < ActiveRecord::Migration[7.1]
  def change
    add_column :finance_documents, :drive_filename, :string
    add_column :accounts, :finance_drive_changes_token, :string
  end
end
