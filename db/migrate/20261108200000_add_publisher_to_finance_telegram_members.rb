# frozen_string_literal: true

class AddPublisherToFinanceTelegramMembers < ActiveRecord::Migration[7.1]
  def change
    add_reference :finance_telegram_members, :publisher, foreign_key: { on_delete: :nullify }
  end
end
