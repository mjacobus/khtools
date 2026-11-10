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
                                       drive_url: 'https://drive.example/s24',
                                       cash_holder_telegram_id: 7, cash_holder_name: 'Bia <Lima>',
                                       **attributes)
  end

  def remind
    described_class.new(account:, telegram:).remind(today:)
    telegram.sent
  end

  it 'sends one reminder per S-24, mentioning who holds the cash, with the amount and the file' do
    s24(4)
    s24(7, amount_cents: 2_000)

    expect(remind.pluck(:text)).to match([
      '⏰ <a href="tg://user?id=7">Bia &lt;Lima&gt;</a>, dinheiro a entregar ao servo de contas' \
      "\n💵 Dinheiro do S-24 de qua 04/11 (R$ 315,00)\nEstá com: Bia &lt;Lima&gt;\nPix: pendente" \
      "\n<a href=\"https://drive.example/s24\">📄 Ver o S-24</a>",
      a_string_including('S-24 de sáb 07/11 (R$ 20,00)')
    ])
  end

  it 'has the buttons, which then update this message' do
    document = s24(4)

    expect(remind.last).to include(html: true, buttons: Finance::Messages.cash_buttons(document))
    expect(document.reload.cash_message_id).to eq(501) # the first id FakeTelegram hands out
  end

  it 'names the accounts servant and helpers, mentioning them' do
    account.finance_telegram_members.create!(telegram_id: 1, name: 'Marcelo', role: 'servant')
    account.finance_telegram_members.create!(telegram_id: 2, name: 'Caio', role: 'helper')
    account.finance_telegram_members.create!(telegram_id: 3, name: 'Davi', role: 'overseer')
    s24(4)

    expect(remind.last[:text].lines.first).to end_with(
      'a entregar a <a href="tg://user?id=1">Marcelo</a> ou ' \
      "<a href=\"tg://user?id=2\">Caio</a>\n"
    )
  end

  it 'says who to hand it to when someone else made the Pix' do
    s24(4, cash_pix_at: Time.current, cash_pix_by: 'Marcelo', cash_pix_by_telegram_id: 9)

    expect(remind.last[:text]).to include('(entregar a Marcelo, que fez o Pix)')
  end

  it 'leaves out cash received or paid by Pix by its holder, S-24s without a holder and today' do
    s24(4, cash_received_at: Time.current)
    s24(5, cash_pix_at: Time.current, cash_pix_by_telegram_id: 7)
    s24(7, cash_holder_name: nil, cash_holder_telegram_id: nil)
    s24(9)

    expect(remind).to be_empty
  end
end
