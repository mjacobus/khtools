# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::CashReminders do
  let(:telegram) { FakeTelegram.new }
  let(:account) do
    factories.accounts.create.tap { |account| account.update!(finance_telegram_chat_id: '-100') }
  end
  let(:today) { Date.new(2026, 11, 9) }

  def s24(day, **attributes)
    factories.finance_documents.create(account:, state: 'archived', kind: 's24',
                                       competence: '2026-11', amount_cents: 31_500,
                                       document_date: Date.new(2026, 11, day),
                                       cash_holder_telegram_id: 7, cash_holder_name: 'Bia <Lima>',
                                       **attributes)
  end

  def remind
    described_class.new(account:, telegram:).remind(today:)
    telegram.sent.last
  end

  it 'mentions who still holds the cash of past meetings' do
    s24(4)

    expect(remind).to include(html: true, text: "💵 Dinheiro a entregar ao servo de contas\n" \
                                                '• qua 04/11 · R$ 315,00 · com ' \
                                                '<a href="tg://user?id=7">Bia &lt;Lima&gt;</a>')
  end

  it 'names the accounts servant and helpers, mentioning them' do
    account.finance_telegram_members.create!(telegram_id: 1, name: 'Marcelo', role: 'servant')
    account.finance_telegram_members.create!(telegram_id: 2, name: 'Caio', role: 'helper')
    account.finance_telegram_members.create!(telegram_id: 3, name: 'Davi', role: 'overseer')
    s24(4)

    expect(remind[:text]).to start_with(
      '💵 Dinheiro a entregar a <a href="tg://user?id=1">Marcelo</a> ou ' \
      "<a href=\"tg://user?id=2\">Caio</a>\n"
    )
  end

  it 'leaves out cash already received, S-24s without a holder and today' do
    s24(4, cash_received_at: Time.current)
    s24(7, cash_holder_name: nil, cash_holder_telegram_id: nil)
    s24(9)

    expect(remind).to be_nil
  end
end
