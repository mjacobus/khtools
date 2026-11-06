# frozen_string_literal: true

# Someone the finance bot saw in the group, so the integrations page can show names
# instead of Telegram ids. The Bot API can't list a group's members.
class Db::FinanceTelegramMember < ApplicationRecord
  belongs_to :account, class_name: 'Db::Account'

  def self.remember(account:, telegram_id:, name:)
    member = account.finance_telegram_members.find_or_initialize_by(telegram_id:)
    member.update!(name: name.presence || member.name)
  rescue ActiveRecord::RecordNotUnique
    nil # the same person arrived twice at the same time
  end
end
