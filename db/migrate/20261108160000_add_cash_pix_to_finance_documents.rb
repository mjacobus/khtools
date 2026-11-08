# frozen_string_literal: true

# The treasurer makes the Pix of an S-24 whether or not the cash has arrived; tracked apart.
class AddCashPixToFinanceDocuments < ActiveRecord::Migration[7.1]
  def change
    change_table :finance_documents, bulk: true do |t|
      t.datetime :cash_pix_at
      t.string :cash_pix_by
    end
  end
end
