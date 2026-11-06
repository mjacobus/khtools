# frozen_string_literal: true

class AddPeopleAndCorrectionsToFinanceDocuments < ActiveRecord::Migration[7.1]
  def change
    change_table :finance_documents, bulk: true do |t|
      t.bigint :sent_by_telegram_id
      t.string :sent_by_name
      t.bigint :confirmed_by_telegram_id
      t.json :corrections, null: false, default: []
    end
  end
end
