# frozen_string_literal: true

# Something to do every month on a given day (like paying the internet bill). It stays pending
# from that day until marked done for the month; a day the month lacks means its last day.
class Db::FinanceReminder < ApplicationRecord
  belongs_to :account, class_name: 'Db::Account'

  validates :title, presence: true
  validates :day, inclusion: { in: 1..31 }

  def pending?(today)
    today >= today.change(day: [day, today.end_of_month.day].min) &&
      done_month != Finance::Competence.month(today)
  end

  def done!(today)
    update!(done_month: Finance::Competence.month(today))
  end
end
