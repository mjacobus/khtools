# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::BillReminders do
  let(:telegram) { FakeTelegram.new }
  let(:account) do
    factories.accounts.create.tap do |account|
      account.update!(finance_telegram_chat_id: '-1001234567890')
    end
  end
  let(:today) { Date.new(2026, 10, 10) }

  def bill(description, due_date, **attributes)
    factories.finance_documents.create(account:, state: 'archived', kind: 'bill', description:,
                                       competence: '2026-10', due_date:, amount_cents: 7412,
                                       **attributes)
  end

  def bills(days_by_name)
    days_by_name.each { |name, days| bill(name, today + days) }
  end

  def remind
    described_class.new(account:, telegram:).remind(today:)
    telegram.sent.last
  end

  it 'lists the bills due in the next days and the overdue ones, by due date' do
    bills('Água' => 3, 'Luz' => 0, 'Gás' => -2, 'Internet' => 1)

    expect(remind).to include(chat_id: '-1001234567890', text: <<~TEXT.strip)
      ⏰ Faturas em aberto
      • Fatura Gás · R$ 74,12 · vencida há 2 dias (08/10)
      • Fatura Luz · R$ 74,12 · vence hoje (10/10)
      • Fatura Internet · R$ 74,12 · vence amanhã (11/10)
      • Fatura Água · R$ 74,12 · vence em 3 dias (13/10)
      Marque como paga em Contas › Documentos.
    TEXT
  end

  it 'stays quiet when nothing is due soon' do
    bill('Água', today + 4)
    bill('Luz', today - 1, paid_on: today - 2)
    bill('Antiga', nil)

    expect(remind).to be_nil
  end

  it 'leaves out other accounts' do
    factories.finance_documents.create(state: 'archived', kind: 'bill', due_date: today)

    expect(remind).to be_nil
  end
end
