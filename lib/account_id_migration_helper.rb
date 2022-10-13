# frozen_string_literal: true

module AccountIdMigrationHelper
  private

  def add_account_ownership(table_name, required: true) # rubocop:disable Metrics/MethodLength
    add_reference table_name, :account, null: !required, foreign_key: true

    unless Rails.env.test?
      id ||= first_id

      unless id
        sql = <<~SQL.squish
          INSERT INTO accounts (congregation_name, created_at, updated_at)#{' '}
          VALUES ('default_congregation', NOW(), NOW())
        SQL
        execute(sql)
      end

      execute("UPDATE #{table_name} set account_id = #{first_id}")

      if required
        change_column_null(table_name, :account_id, false)
      end
    end
  end

  def remove_account_ownership(table_name, required: true)
    remove_reference table_name, :account, null: !required, foreign_key: true
  end

  def first_id
    res = execute('SELECT id FROM accounts ORDER BY id LIMIT 1')
    res.first ? res.first['id'] : nil
  end
end
