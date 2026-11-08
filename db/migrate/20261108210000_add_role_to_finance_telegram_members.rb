# frozen_string_literal: true

class AddRoleToFinanceTelegramMembers < ActiveRecord::Migration[7.1]
  def change
    add_column :finance_telegram_members, :role, :string
  end
end
