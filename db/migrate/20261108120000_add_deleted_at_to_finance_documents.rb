# frozen_string_literal: true

# Files deleted in Drive are soft deleted (hidden by the default scope) instead of flagged.
class AddDeletedAtToFinanceDocuments < ActiveRecord::Migration[7.1]
  def up
    add_column :finance_documents, :deleted_at, :datetime
    add_index :finance_documents, :deleted_at
    execute <<~SQL.squish
      UPDATE finance_documents SET deleted_at = updated_at,
        flags = NULLIF(TRIM(REPLACE(REPLACE(flags, 'trashed', ''), ',,', ','), ','), '')
      WHERE flags LIKE '%trashed%'
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE finance_documents SET flags = COALESCE(flags || ',', '') || 'trashed'
      WHERE deleted_at IS NOT NULL
    SQL
    remove_column :finance_documents, :deleted_at
  end
end
