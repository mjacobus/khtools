# frozen_string_literal: true

class CreateFinanceReminders < ActiveRecord::Migration[7.1]
  def change
    create_table :finance_reminders do |t|
      t.references :account, null: false, foreign_key: true
      t.string :title, null: false
      t.integer :day, null: false
      t.string :done_month
      t.timestamps
    end
  end
end
