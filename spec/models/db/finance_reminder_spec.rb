# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::FinanceReminder do
  let(:account) { factories.accounts.create }

  def reminder(day: 10, done_month: nil)
    account.finance_reminders.create!(title: 'Pagamento internet', day:, done_month:)
  end

  it 'is pending from its day until marked done for the month' do
    internet = reminder

    expect(internet.pending?(Date.new(2026, 11, 9))).to be(false)
    expect(internet.pending?(Date.new(2026, 11, 10))).to be(true)
    expect(internet.pending?(Date.new(2026, 11, 25))).to be(true)

    internet.done!(Date.new(2026, 11, 12))

    expect(internet.pending?(Date.new(2026, 11, 25))).to be(false)
    expect(internet.pending?(Date.new(2026, 12, 10))).to be(true)
  end

  it 'falls on the last day of shorter months' do
    expect(reminder(day: 31).pending?(Date.new(2027, 2, 28))).to be(true)
  end

  it 'needs a title and a day of the month' do
    expect(account.finance_reminders.new(title: '', day: 32)).not_to be_valid
  end
end
