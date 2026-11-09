# frozen_string_literal: true

# "Cuida das contas" and "Recolhe" become the congregation's own names for the roles.
class RenameFinanceTelegramMemberRoles < ActiveRecord::Migration[7.1]
  RENAMES = { 'treasurer' => 'servant', 'collector' => 'helper' }.freeze

  def up
    RENAMES.each { |from, to| rename(from, to) }
  end

  def down
    RENAMES.each { |from, to| rename(to, from) }
  end

  private

  def rename(from, to)
    execute("UPDATE finance_telegram_members SET role = '#{to}' WHERE role = '#{from}'")
  end
end
