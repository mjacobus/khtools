# frozen_string_literal: true

# Who holds the cash of an S-24 until the treasurer gets it (to deposit by Pix).
class AddCashHandoverToFinanceDocuments < ActiveRecord::Migration[7.1]
  def change
    change_table :finance_documents, bulk: true do |t|
      t.bigint :cash_holder_telegram_id
      t.string :cash_holder_name
      t.datetime :cash_received_at
      t.string :cash_received_by
      t.bigint :cash_message_id
    end
  end
end
