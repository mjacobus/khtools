# frozen_string_literal: true

class CreateFinanceTelegramMembers < ActiveRecord::Migration[7.1]
  def change
    create_table :finance_telegram_members do |t|
      t.references :account, null: false, foreign_key: { to_table: :accounts }
      t.bigint :telegram_id, null: false
      t.string :name
      t.timestamps
    end
    add_index :finance_telegram_members, %i[account_id telegram_id], unique: true
  end
end
