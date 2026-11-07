# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::ChecklistReminders do
  let(:telegram) { FakeTelegram.new }
  let(:account) do
    factories.accounts.create.tap { |account| account.update!(finance_telegram_chat_id: '-100') }
  end

  def document(kind, competence, **attributes)
    factories.finance_documents.create(account:, state: 'archived', kind:, competence:,
                                       **attributes)
  end

  def remind(today)
    described_class.new(account:, telegram:).remind(today:)
    telegram.sent.last&.fetch(:text)
  end

  it 'asks for the S-24 of the meetings in the last week' do
    document('s24', '2026-11', document_date: Date.new(2026, 11, 4))

    expect(remind(Date.new(2026, 11, 9))).to eq("📋 Faltando nas contas\n• S-24 de sáb 07/11")
  end

  it 'asks for the documents of the month that ended, on the 5th, 10th, 15th and 20th' do
    %w[statement s26 s30 remittance_record].each { |kind| document(kind, '2026-11') }
    document('audit_report', '2026-11')

    expect(remind(Date.new(2026, 12, 10))).to include('• Comprovante Remessa Betel de 2026-11')
    expect(remind(Date.new(2026, 12, 11))).not_to include('2026-11')
  end

  it 'asks for the audit report after the last month of an audited quarter' do
    expect(remind(Date.new(2026, 12, 5))).to include('• S-25b de 2026-11')
    expect(remind(Date.new(2026, 11, 5))).not_to include('S-25b')
  end

  it 'stays quiet when nothing is missing' do
    [28, 31].each { |day| document('s24', '2026-10', document_date: Date.new(2026, 10, day)) }

    expect(remind(Date.new(2026, 11, 2))).to be_nil
  end
end
