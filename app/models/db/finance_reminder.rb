# frozen_string_literal: true

# Something to do every month on a given day (like paying the internet bill). It stays pending
# from that day until marked done for the month; a day the month lacks means its last day.
class Db::FinanceReminder < ApplicationRecord
  belongs_to :account, class_name: 'Db::Account'
  # Who takes care of it: the bot mentions them in the group.
  belongs_to :responsible, optional: true, class_name: 'Db::FinanceTelegramMember',
                           foreign_key: :finance_telegram_member_id, inverse_of: false

  validates :title, presence: true
  validates :day, inclusion: { in: 1..31 }
  validate :responsible_of_the_account

  def pending?(today)
    today >= today.change(day: [day, today.end_of_month.day].min) &&
      done_month != Finance::Competence.month(today)
  end

  def done!(today)
    update!(done_month: Finance::Competence.month(today))
  end

  private

  def responsible_of_the_account
    if responsible && responsible.account_id != account_id
      errors.add(:finance_telegram_member_id, :invalid)
    end
  end
end
