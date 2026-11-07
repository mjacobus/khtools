# frozen_string_literal: true

# Bills get a due date and a payment date; a payment receipt points to the bill it paid.
class AddPaymentToFinanceDocuments < ActiveRecord::Migration[7.1]
  def change
    add_column :finance_documents, :due_date, :date
    add_column :finance_documents, :paid_on, :date
    add_reference :finance_documents, :bill, foreign_key: { to_table: :finance_documents }
  end
end
