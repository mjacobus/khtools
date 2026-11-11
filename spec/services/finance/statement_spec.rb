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
end
