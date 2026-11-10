# frozen_string_literal: true

class AddCashPixByTelegramIdToFinanceDocuments < ActiveRecord::Migration[7.1]
  def change
    add_column :finance_documents, :cash_pix_by_telegram_id, :bigint
  end
end
