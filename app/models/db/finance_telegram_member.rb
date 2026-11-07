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

  # The only member whose name has every word of a hand-printed name ("CAIO S." finds
  # "Caio Souza"), accents and case aside; nil when none or several match.
  def self.matching(account:, name:)
    words = words(name)
    found = account.finance_telegram_members.select do |member|
      member_words = words(member.name)
      words.any? && words.all? { |word| member_words.any? { |other| other.start_with?(word) } }
    end
    found.one? ? found.first : nil
  end

  def self.words(text)
    I18n.transliterate(text.to_s).downcase.scan(/[a-z]+/)
  end
end
