# frozen_string_literal: true

# Meeting days without a collection (special events) or moved to another day.
class CreateFinanceMeetingExceptions < ActiveRecord::Migration[7.1]
  def change
    create_table :finance_meeting_exceptions do |t|
      t.references :account, null: false, foreign_key: true
      t.date :date, null: false
      t.date :moved_to
      t.timestamps
    end
    add_index :finance_meeting_exceptions, %i[account_id date], unique: true
  end
end
