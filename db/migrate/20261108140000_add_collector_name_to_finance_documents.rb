# frozen_string_literal: true

# Name printed by whoever collected an S-24 (first signature), to guess who holds the cash.
class AddCollectorNameToFinanceDocuments < ActiveRecord::Migration[7.1]
  def change
    add_column :finance_documents, :collector_name, :string
  end
end
