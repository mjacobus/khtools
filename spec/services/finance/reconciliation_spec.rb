# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::Reconciliation do
  let(:account) { factories.accounts.create }
  let(:s24) { document('s24', Date.new(2026, 10, 1), 15_000) }
  let(:s24_late) { document('s24', Date.new(2026, 10, 28), 8_000) }
  let(:receipt) { document('payment_receipt', Date.new(2026, 10, 2), 107_449) }
  let(:remittance) do
    document('remittance_record', Date.new(2026, 11, 2), 30_000, competence: '2026-10')
  end

  # September's S-24 went in on 30/09: it is not part of October.
  before do
    document('s24', Date.new(2026, 9, 29), 20_000)
    [s24, s24_late, receipt, remittance]
  end

  def reconciliation
    text = Rails.root.join('spec/fixtures/finance/statement.txt').read
    described_class.new(account:, month: '2026-10', lines: Finance::Statement.parse(text),
                        holder: Finance::Statement.holder(text), opening_cents: 120_000)
  end

  def document(kind, date, cents, competence: date.strftime('%Y-%m'))
    factories.finance_documents.create(account:, state: 'archived', kind:, document_date: date,
                                       amount_cents: cents, competence:)
  end

  it "explains each of the month's statement lines" do
    reasons = reconciliation.entries.map { |entry| [entry.line.doc, entry.reason, entry.document] }

    expect(reasons).to eq([['100002', :deposit, s24], ['100003', :donation, nil],
                           ['100004', :expense, receipt], ['100005', :interest, nil]])
  end

  it 'lists the S-24s not deposited by the end of the month and the remittance still to go' do
    expect(reconciliation.undeposited).to eq([s24_late])
    expect(reconciliation.pending_remittances).to eq([remittance])
    expect(reconciliation.unpaid).to be_empty
  end

  it 'closes the documents and the statement on the same balance' do
    expect(reconciliation.statement_cents).to eq(32_671)
    expect(reconciliation.confronto_cents).to eq(32_671 + 8_000 - 30_000)
    expect(reconciliation.expected_cents).to eq(120_000 + 23_000 + 5_000 + 120 - 107_449 - 30_000)
    expect(reconciliation.difference_cents).to eq(0)
  end

  it "flags the holder's Pix that matches no S-24, and the difference it leaves" do
    s24.update!(amount_cents: 18_000)

    expect(reconciliation.entries.first.reason).to eq(:unexplained_deposit)
    expect(reconciliation.undeposited).to eq([s24, s24_late])
    expect(reconciliation.difference_cents).to eq(-15_000)
  end

  it 'has no expected balance without an opening balance' do
    reconciliation = described_class.new(account:, month: '2026-10', lines: [], holder: nil,
                                         opening_cents: nil)

    expect([reconciliation.expected_cents, reconciliation.difference_cents]).to eq([nil, nil])
  end
end
