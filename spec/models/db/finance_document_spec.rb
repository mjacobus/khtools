# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::FinanceDocument do
  subject(:document) { factories.finance_documents.build }

  it { is_expected.to belong_to(:account).class_name('Db::Account') }
  it { is_expected.to validate_presence_of(:telegram_chat_id) }
  it { is_expected.to validate_presence_of(:telegram_message_id) }
  it { is_expected.to validate_presence_of(:telegram_file_id) }

  it 'needs no Telegram message when it came from the backfill, however many there are' do
    account = factories.accounts.create
    2.times do
      backfilled = described_class.new(account:, state: 'archived', flags: 'backfill',
                                       drive_file_id: SecureRandom.hex)

      expect(backfilled.save).to be(true)
    end
  end

  it { is_expected.to validate_inclusion_of(:state).in_array(described_class::STATES) }
  it { is_expected.to validate_inclusion_of(:kind).in_array(described_class::KINDS) }

  describe 'audit report month' do
    let(:audit) { factories.finance_documents.create(kind: 'audit_report', competence: '2026-08') }

    it 'must be the last month of an audit period' do
      audit.competence = '2026-09'

      expect(audit).not_to be_valid
      expect(audit.errors[:competence].first)
        .to eq('2026-09 não é o último mês de um período de auditoria. O S-25b fica em ' \
               'fevereiro, maio, agosto ou novembro (S-27b par. 54): use 2026-08.')
    end

    it 'leaves alone a report already filed elsewhere' do
      audit.update_column(:competence, '2026-09')

      expect(audit.reload.update(description: 'Junho a agosto')).to be(true)
    end
  end

  it 'defaults to received/unknown' do
    expect(described_class.new).to have_attributes(state: 'received', kind: 'unknown')
  end

  it 'rejects the same message twice in the same chat and account' do
    existing = factories.finance_documents.create
    duplicate = factories.finance_documents.build(
      account: existing.account,
      telegram_chat_id: existing.telegram_chat_id,
      telegram_message_id: existing.telegram_message_id
    )

    expect(duplicate).not_to be_valid
    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  describe '.stuck' do
    it 'returns only old received and confirmed documents' do
      old_received = factories.finance_documents.create(state: 'received',
                                                        updated_at: 11.minutes.ago)
      old_confirmed = factories.finance_documents.create(state: 'confirmed',
                                                         updated_at: 11.minutes.ago)
      factories.finance_documents.create(state: 'received')
      factories.finance_documents.create(state: 'suggested', updated_at: 11.minutes.ago)
      factories.finance_documents.create(state: 'archived', updated_at: 11.minutes.ago)

      expect(described_class.stuck).to contain_exactly(old_received, old_confirmed)
    end
  end

  describe '#replaced_document' do
    let(:account) { factories.accounts.create }

    def archived(**attributes)
      factories.finance_documents.create(account:, state: 'archived', kind: 's26',
                                         competence: '2026-09', mime_type: 'application/pdf',
                                         drive_file_id: 'OLD', **attributes)
    end

    def incoming(**attributes)
      factories.finance_documents.build(account:, state: 'confirmed', kind: 's26',
                                        competence: '2026-09', mime_type: 'application/pdf',
                                        **attributes)
    end

    it 'is the archived file of the same monthly kind and month' do
      previous = archived

      expect(incoming.replaced_document).to eq(previous)
    end

    it 'is nil for other months, other names and kinds that are not monthly' do
      archived(competence: '2026-08')
      archived(mime_type: 'image/jpeg')
      archived(kind: 'bill', competence: '2026-09', document_date: Date.new(2026, 9, 1),
               amount_cents: 100)

      expect(incoming.replaced_document).to be_nil
      expect(incoming(kind: 'bill', document_date: Date.new(2026, 9, 1), amount_cents: 100)
        .replaced_document).to be_nil
    end

    it 'ignores documents of other accounts and files the bot did not upload' do
      archived(account: factories.accounts.create)
      archived(drive_file_id: nil)
      archived(flags: 'backfill', telegram_message_id: nil, telegram_chat_id: nil,
               telegram_file_id: nil)

      expect(incoming.replaced_document).to be_nil
    end
  end

  describe '#assign_competence' do
    it 'uses the default rules' do
      doc = described_class.new(kind: 's24', document_date: Date.new(2026, 11, 4))

      expect { doc.assign_competence }.to change(doc, :competence).to('2026-11')
    end

    it 'dates remittances on the last day of their month' do
      doc = described_class.new(kind: 'remittance_receipt', document_date: Date.new(2026, 11, 2))
      doc.assign_competence

      expect(doc).to have_attributes(competence: '2026-10', document_date: Date.new(2026, 10, 31))
    end

    it 'keeps the period of monthly documents' do
      doc = described_class.new(kind: 'statement')
      doc.assign_competence(period: '2026-10')

      expect(doc.competence).to eq('2026-10')
    end
  end

  it 'manages flags' do
    doc = described_class.new
    doc.add_flag('encrypted_original')
    doc.add_flag('encrypted_original')

    expect(doc.flags).to eq('encrypted_original')
    expect(doc).to be_flagged('encrypted_original')
  end

  describe 'bill payment' do
    let(:today) { Date.new(2026, 10, 10) }

    def bill(**attributes)
      described_class.new(kind: 'bill', **attributes)
    end

    it 'is paid once it has a payment date, late when after the due date' do
      expect(bill(due_date: today, paid_on: today).payment_status(today:)).to eq('paid')
      expect(bill(due_date: today, paid_on: today + 1).payment_status(today:)).to eq('paid_late')
    end

    it 'is open until the due date and overdue after it' do
      expect(bill(due_date: today).payment_status(today:)).to eq('open')
      expect(bill(due_date: today - 1).payment_status(today:)).to eq('overdue')
    end

    it 'has no status without a due date (old bills from the backfill)' do
      expect(bill.payment_status(today:)).to be_nil
    end
  end
end
