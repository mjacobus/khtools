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

  it 'reminds every morning what is pending, with a button to mark each one done' do
    internet = account.finance_reminders.find_by(day: 10)

    expect(remind(Date.new(2026, 11, 12))).to include(
      text: "🔔 Lembretes\n• Pagamento internet (dia 10)\nToque no botão quando estiver feito.",
      buttons: [[['✅ Pagamento internet', "fin:reminder_done:#{internet.id}"]]]
    )
  end

  it 'mentions who is responsible' do
    member = account.finance_telegram_members.create!(telegram_id: 77, name: 'Caio & Cia')
    account.finance_reminders.find_by(day: 10).update!(responsible: member)

    expect(remind(Date.new(2026, 11, 12))).to include(
      text: a_string_including('• Pagamento internet (dia 10) · ' \
                               '<a href="tg://user?id=77">Caio &amp; Cia</a>'),
      html: true
    )
  end

  it 'says nothing when nothing is pending' do
    account.finance_reminders.find_by(day: 10).done!(Date.new(2026, 11, 12))

    expect(remind(Date.new(2026, 11, 12))).to be_nil
  end
end
