# frozen_string_literal: true

class CreateDbMeetingAttendanceMeetings < ActiveRecord::Migration[6.1]
  def change
    create_table :ma_meetings do |t|
      t.string :title, null: false

      t.timestamps
    end
  end
end
