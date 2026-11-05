# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::Competence do
  def default_for(kind, date, period = nil)
    described_class.default_for(kind:, document_date: date && Date.parse(date), period:)
  end

  it 'uses the document month for s24, payment receipts and bills' do
    expect(default_for('s24', '2026-11-04')).to eq('2026-11')
    expect(default_for('payment_receipt', '2026-10-26')).to eq('2026-10')
    expect(default_for('bill', '2026-10-10')).to eq('2026-10')
  end

  it 'uses the period for monthly documents, falling back to the date' do
    expect(default_for('statement', '2026-11-03', '2026-10')).to eq('2026-10')
    expect(default_for('s30', '2026-11-03')).to eq('2026-11')
  end

  it 'moves early-month remittances to the previous month' do
    expect(default_for('remittance_record', '2026-11-02')).to eq('2026-10')
    expect(default_for('remittance_receipt', '2026-11-10')).to eq('2026-10')
    expect(default_for('remittance_record', '2026-10-28')).to eq('2026-10')
  end

  it 'returns nil without date or period' do
    expect(default_for('s24', nil)).to be_nil
  end

  it 'gives the last day of the month as the remittance date' do
    expect(described_class.remittance_date(competence: '2026-10')).to eq(Date.new(2026, 10, 31))
  end
end
