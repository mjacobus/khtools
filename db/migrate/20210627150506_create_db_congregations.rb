# frozen_string_literal: true

class CreateDbCongregations < ActiveRecord::Migration[6.1]
  def change
    create_table :congregations do |t|
      t.string :name
      t.string :address
      t.string :primary_contact_person
      t.string :primary_contact_phone
      t.string :primary_contact_email
      t.string :weekend_meeting_time
      t.boolean :local, default: false

      t.timestamps
    end
  end
end
