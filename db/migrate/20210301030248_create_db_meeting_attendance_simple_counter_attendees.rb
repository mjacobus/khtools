# frozen_string_literal: true

class CreateDbMeetingAttendanceSimpleCounterAttendees < ActiveRecord::Migration[6.1]
  def change
    create_table :ma_simple_counter_attendees do |t|
      t.string :name, null: false
      t.integer :amount, default: 1
      t.integer :meeting_id

      t.timestamps
    end

    add_foreign_key :ma_simple_counter_attendees, :ma_meetings, column: :meeting_id
  end
end
