# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Db::FinanceDocument do
  subject(:document) { factories.finance_documents.build }

  it { is_expected.to belong_to(:account).class_name('Db::Account') }
  it { is_expected.to validate_presence_of(:telegram_chat_id) }
  it { is_expected.to validate_presence_of(:telegram_message_id) }
  it { is_expected.to validate_presence_of(:telegram_file_id) }
  it { is_expected.to validate_inclusion_of(:state).in_array(described_class::STATES) }
  it { is_expected.to validate_inclusion_of(:kind).in_array(described_class::KINDS) }

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
end
