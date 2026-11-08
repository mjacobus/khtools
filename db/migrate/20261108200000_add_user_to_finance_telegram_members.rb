# frozen_string_literal: true

class AddUserToFinanceTelegramMembers < ActiveRecord::Migration[7.1]
  def change
    add_reference :finance_telegram_members, :user, foreign_key: { on_delete: :nullify }
  end
end
