# frozen_string_literal: true

# Documents registered by the backfill are already in Drive and never came from Telegram.
class AllowFinanceDocumentsWithoutTelegram < ActiveRecord::Migration[7.1]
  def change
    change_column_null :finance_documents, :telegram_chat_id, true
    change_column_null :finance_documents, :telegram_message_id, true
    change_column_null :finance_documents, :telegram_file_id, true
  end
end
