# frozen_string_literal: true

# Someone the finance bot saw in the group, so the integrations page can show names
# instead of Telegram ids. The Bot API can't list a group's members.
class Db::FinanceTelegramMember < ApplicationRecord
  belongs_to :account, class_name: 'Db::Account'
  belongs_to :publisher, optional: true, class_name: 'Db::Publisher'

  # Who confirms documents is kept apart, on the account: anyone may have that and a role.
  ROLES = { 'treasurer' => 'Cuida das contas', 'collector' => 'Recolhe' }.freeze

  validates :role, inclusion: { in: ROLES.keys }, allow_nil: true
  validate :publisher_of_the_account

  # How the bot calls them: the linked publisher's name, else the one they use on Telegram.
  def display_name
    publisher&.name || name
  end

  def self.remember(account:, telegram_id:, name:)
    member = account.finance_telegram_members.find_or_initialize_by(telegram_id:)
    member.update!(name: name.presence || member.name)
  rescue ActiveRecord::RecordNotUnique
    nil # the same person arrived twice at the same time
  end

  # The only member whose name (on Telegram or of the linked publisher) has every word of a
  # hand-printed name ("CAIO S." finds "Caio Souza"), accents and case aside; nil when none
  # or several match.
  def self.matching(account:, name:)
    words = words(name)
    found = account.finance_telegram_members.includes(:publisher).select do |member|
      known_names = [member.name, member.publisher&.name]
      words.any? && known_names.any? { |known| abbreviates?(words, known) }
    end
    found.one? ? found.first : nil
  end

  def self.abbreviates?(words, name)
    known = words(name)
    words.all? { |word| known.any? { |other| other.start_with?(word) } }
  end

  def self.words(text)
    I18n.transliterate(text.to_s).downcase.scan(/[a-z]+/)
  end

  private

  def publisher_of_the_account
    if publisher && publisher.account_id != account_id
      errors.add(:publisher, :invalid)
    end
  end
end
