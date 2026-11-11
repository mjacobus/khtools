# frozen_string_literal: true

class CreateFinanceBalances < ActiveRecord::Migration[7.1]
  def change
    create_table :finance_balances do |t|
      t.references :account, null: false, foreign_key: { to_table: :accounts }
      t.string :competence, null: false
      t.integer :opening_cents, null: false
      t.timestamps
    end
    add_index :finance_balances, %i[account_id competence], unique: true
  end
end
