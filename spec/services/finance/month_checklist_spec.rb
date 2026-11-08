# frozen_string_literal: true

require 'rails_helper'

# September 2026: Wednesdays 2, 9, 16, 23, 30 and Saturdays 5, 12, 19, 26.
RSpec.describe Finance::MonthChecklist do
  let(:account) { factories.accounts.create }
  let(:today) { Date.new(2026, 9, 13) }

  def document(kind, **attributes)
    factories.finance_documents.create(account:, state: 'archived', kind:, competence: '2026-09',
                                       **attributes)
  end

  def items(month = '2026-09')
    described_class.new(account:, month:, today:).items
  end

  def meetings(month = '2026-09')
    items(month).select { |item| item.kind == 's24' }.to_h { |item| [item.date.day, item.done] }
  end

  it 'expects one S-24 per Wednesday and Saturday up to today' do
    document('s24', document_date: Date.new(2026, 9, 2))
    document('s24', document_date: Date.new(2026, 9, 9))

    expect(meetings).to eq(2 => true, 5 => false, 9 => true, 12 => false)
  end

  it 'skips meetings that did not happen and expects moved ones on their new day' do
    account.finance_meeting_exceptions.create!(date: Date.new(2026, 9, 5))
    account.finance_meeting_exceptions.create!(date: Date.new(2026, 9, 9),
                                               moved_to: Date.new(2026, 9, 10))
    document('s24', document_date: Date.new(2026, 9, 10))

    expect(meetings).to eq(2 => false, 10 => true, 12 => false)
  end

  it 'expects the monthly documents' do
    document('s26')

    expect(items.reject { |item| item.kind == 's24' }.to_h { |item| [item.kind, item.done] })
      .to eq('statement' => false, 'betel_statement' => false, 's26' => true, 's30' => false,
             'remittance_record' => false, 'remittance_receipt' => false)
  end

  it 'only counts what is filed in Drive' do
    document('s26', state: 'suggested')
    document('s30', deleted_at: Time.current)

    expect(items.to_h { |item| [item.kind, item.done] }).to include('s26' => false, 's30' => false)
  end

  it 'expects the audit report in the last month of each audited quarter' do
    expect(items('2026-11').map(&:kind)).to include('audit_report')
    expect(items('2026-10').map(&:kind)).not_to include('audit_report')
  end
end
