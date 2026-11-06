# frozen_string_literal: true

class CreateFinanceDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :finance_documents do |t|
      t.references :account, null: false, foreign_key: true
      t.bigint :telegram_chat_id, null: false
      t.bigint :telegram_message_id, null: false
      t.string :telegram_file_id, null: false
      t.bigint :bot_message_id
      t.bigint :edit_prompt_message_id
      t.string :original_filename
      t.string :mime_type
      t.string :sha256
      t.string :kind, null: false, default: 'unknown'
      t.string :competence
      t.date :document_date
      t.integer :amount_cents
      t.integer :congregation_cents
      t.integer :worldwide_cents
      t.string :description
      t.string :value_source
      t.string :state, null: false, default: 'received'
      t.string :drive_file_id
      t.string :drive_url
      t.string :confirmed_by
      t.datetime :confirmed_at
      t.text :last_error
      t.string :flags
      t.timestamps
    end

    add_index :finance_documents, %i[account_id telegram_chat_id telegram_message_id],
              unique: true, name: 'index_finance_documents_on_telegram_message'
    add_index :finance_documents, %i[account_id sha256]
  end
end
