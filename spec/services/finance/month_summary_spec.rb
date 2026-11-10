# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::MonthSummary do
  subject(:summary) { described_class.new(account:, month: '2026-09') }

  let(:account) { factories.accounts.create(finance_resolution_cents: 80_000) }

  def document(kind, **attributes)
    factories.finance_documents.create(account:, state: 'archived', kind:, competence: '2026-09',
                                       **attributes)
  end

  before do
    document('s24', worldwide_cents: 10_000, congregation_cents: 25_000)
    document('s24', worldwide_cents: 5_050, congregation_cents: nil)
    document('s24', worldwide_cents: 99_900, state: 'suggested')
    document('s24', worldwide_cents: 99_900, competence: '2026-08')
  end

  it 'adds up the filed S-24s of the month by worldwide work and local' do
    expect(summary).to have_attributes(worldwide_cents: 15_050, local_cents: 25_000)
  end

  it 'expects the worldwide donations plus the resolution to go to Betel' do
    expect(summary).to have_attributes(resolution_cents: 80_000, remittance_cents: 95_050)
  end

  it 'reads what the filed TO-62 sent' do
    expect(summary.remitted_cents).to be_nil

    document('remittance_record', amount_cents: 95_050)

    expect(summary.remitted_cents).to eq(95_050)
  end
end
