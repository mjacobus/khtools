# frozen_string_literal: true

class AddWrittenTotalCentsToFinanceDocuments < ActiveRecord::Migration[7.1]
  def change
    add_column :finance_documents, :written_total_cents, :integer
  end
end
