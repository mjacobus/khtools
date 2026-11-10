# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::RecurringReminders do
  let(:telegram) { FakeTelegram.new }
  let(:account) do
    factories.accounts.create.tap do |account|
      account.update!(finance_telegram_chat_id: '-1001234567890')
    end
  end

  def remind(today)
    described_class.new(account:, telegram:).remind(today:)
    telegram.sent.last
  end

  before do
    account.finance_reminders.create!(title: 'Pagamento internet', day: 10)
    account.finance_reminders.create!(title: 'Conferir o extrato', day: 20)
  end

  it 'reminds every morning what is pending until it is marked done' do
    expect(remind(Date.new(2026, 11, 12))).to include(
      text: "🔔 Lembretes\n• Pagamento internet (dia 10)\n" \
            'Marque como feito em Contas › Documentos › Lembretes.'
    )
  end

  it 'says nothing when nothing is pending' do
    account.finance_reminders.find_by(day: 10).done!(Date.new(2026, 11, 12))

    expect(remind(Date.new(2026, 11, 12))).to be_nil
  end
end
