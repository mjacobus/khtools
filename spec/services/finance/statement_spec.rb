# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::Statement do
  let(:text) { Rails.root.join('spec/fixtures/finance/statement.txt').read }

  it 'breaks the statement into dated lines with amount, balance and who' do
    lines = described_class.parse(text)

    expect(lines.size).to eq(6)
    expect(lines.first.to_h).to eq(
      date: Date.new(2026, 9, 30), doc: '100001', history: 'PIX RECEBIDO', cents: 20_000,
      balance_cents: 120_000, who: 'ANA TESOUREIRA'
    )
    expect(lines.map(&:cents)).to eq([20_000, 15_000, 5_000, -107_449, 120, -30_000])
  end

  it 'keeps a line without REM/DES, carrying the date of the day' do
    line = described_class.parse(text)[4]

    expect([line.date, line.history, line.who]).to eq([Date.new(2026, 10, 31), 'RENDIMENTO', nil])
  end

  it "reads the account holder's name" do
    expect(described_class.holder(text)).to eq('ANA TESOUREIRA DA SILVA')
  end

  it 'drops repeated lines when statements overlap' do
    expect(described_class.parse(text + text).size).to eq(6)
  end

  it 'reads a history on the same row as the date and amounts (Invest Fácil)' do
    text = <<~TEXT
      23/06/2026   2573-APLIC.INVEST FACIL                           4973813                                     R$ -2.084,46          R$ 1,00
                   3584-RENTAB.INVEST FACILCRED*                        4973814               R$ 0,03                                    R$ 1,03
    TEXT

    lines = described_class.parse(text)

    expect(lines.map { [_1.date, _1.history, _1.cents, _1.balance_cents] }).to eq(
      [[Date.new(2026, 6, 23), 'APLIC.INVEST FACIL', -208_446, 100],
       [Date.new(2026, 6, 23), 'RENTAB.INVEST FACILCRED*', 3, 103]]
    )
  end
end
