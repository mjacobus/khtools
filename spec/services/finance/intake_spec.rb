# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::Intake do
  include ActiveJob::TestHelper

  let(:chat_id) { -100_555 }
  let(:account) do
    factories.accounts.create.tap do |account|
      account.update!(finance_telegram_chat_id: chat_id.to_s, finance_confirmer_telegram_ids: '42')
    end
  end
  let(:telegram) { FakeTelegram.new }
  let(:intake) { described_class.new(account:, telegram:) }

  def photo_update(message_id: 10, chat: chat_id, update_id: 1)
    { 'update_id' => update_id,
      'message' => { 'message_id' => message_id, 'chat' => { 'id' => chat },
                     'from' => { 'id' => 7 },
                     'photo' => [{ 'file_id' => 'small', 'file_size' => 10 },
                                 { 'file_id' => 'big', 'file_size' => 900 }] } }
  end

  def callback(action, document, from: 42)
    { 'update_id' => 2,
      'callback_query' => { 'id' => 'cb1', 'data' => "fin:#{action}:#{document.id}",
                            'from' => { 'id' => from, 'first_name' => 'Ana' },
                            'message' => { 'message_id' => document.bot_message_id,
                                           'chat' => { 'id' => chat_id } } } }
  end

  def suggested(attributes = {})
    factories.finance_documents.create(
      { account:, telegram_chat_id: chat_id, state: 'suggested', kind: 's24',
        document_date: Date.new(2026, 11, 4), competence: '2026-11',
        amount_cents: 15_000, bot_message_id: 300 }.merge(attributes)
    )
  end

  it 'creates one document per message even if Telegram repeats the update' do
    2.times { intake.handle(update: photo_update) }

    expect(account.finance_documents.count).to eq(1)
    expect(account.finance_documents.first).to have_attributes(
      telegram_file_id: 'big', mime_type: 'image/jpeg', telegram_message_id: 10, state: 'received'
    )
    expect(enqueued_jobs.count { |job| job['job_class'] == 'Finance::SuggestJob' }).to eq(1)
  end

  it 'accepts documents with their file name and type' do
    document = { 'file_id' => 'pdf1', 'file_name' => 'x.pdf', 'mime_type' => 'application/pdf' }
    chat = { 'id' => chat_id }
    update = { 'update_id' => 3,
               'message' => { 'message_id' => 11, 'chat' => chat, 'document' => document } }

    intake.handle(update:)

    expect(account.finance_documents.last).to have_attributes(original_filename: 'x.pdf',
                                                              mime_type: 'application/pdf')
  end

  it 'ignores other chats and messages without files' do
    intake.handle(update: photo_update(chat: -1))
    intake.handle(update: { 'message' => { 'message_id' => 12, 'chat' => { 'id' => chat_id },
                                           'text' => 'oi' } })

    expect(account.finance_documents.count).to eq(0)
  end

  it 'ignores buttons tapped by someone who cannot confirm' do
    document = suggested

    intake.handle(update: callback('confirm', document, from: 8))

    expect(document.reload.state).to eq('suggested')
    expect(telegram.answers).to eq([{ id: 'cb1', text: Finance::Messages::NOT_A_CONFIRMER }])
  end

  it 'confirms and enqueues the archive' do
    document = suggested

    intake.handle(update: callback('confirm', document))

    expect(document.reload).to have_attributes(state: 'confirmed', confirmed_by: 'Ana')
    expect(document.confirmed_at).to be_present
    expect(Finance::ArchiveJob).to have_been_enqueued.with(document.id)
    expect(telegram.edits.last).to include(message_id: 300, text: Finance::Messages::ARCHIVING)
  end

  it 'shows "archiving" before the archive job can report its result' do
    document = suggested
    allow(Finance::ArchiveJob).to receive(:perform_later) do
      telegram.edit_message(chat_id:, message_id: 300, text: 'Arquivado: x')
    end

    intake.handle(update: callback('confirm', document))

    expect(telegram.edits.last[:text]).to eq('Arquivado: x')
  end

  it 'does not confirm without a month' do
    document = suggested(competence: nil)

    intake.handle(update: callback('confirm', document))

    expect(document.reload.state).to eq('suggested')
    expect(telegram.answers.last[:text]).to eq(Finance::Messages::NEEDS_MONTH)
  end

  it 'does not confirm twice' do
    document = suggested(state: 'confirmed')

    intake.handle(update: callback('confirm', document))

    expect(Finance::ArchiveJob).not_to have_been_enqueued
    expect(telegram.answers.last[:text]).to eq(Finance::Messages::ALREADY_HANDLED)
  end

  it 'claims the confirmation atomically when another tap got there first' do
    document = suggested
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(Db::FinanceDocument)
      .to receive(:competence).and_wrap_original do |original|
      Db::FinanceDocument.where(id: document.id).update_all(state: 'confirmed')
      original.call
    end
    # rubocop:enable RSpec/AnyInstance

    intake.handle(update: callback('confirm', document))

    expect(Finance::ArchiveJob).not_to have_been_enqueued
    expect(telegram.answers.last[:text]).to eq(Finance::Messages::ALREADY_HANDLED)
  end

  it 'discards' do
    document = suggested

    intake.handle(update: callback('discard', document))

    expect(document.reload.state).to eq('discarded')
    expect(telegram.edits.last).to include(text: Finance::Messages::DISCARDED)
  end

  describe 'corrections' do
    let(:document) { suggested }

    before { intake.handle(update: callback('edit', document)) }

    def reply(text, from: 42)
      prompt_id = document.reload.edit_prompt_message_id
      { 'update_id' => 4,
        'message' => { 'message_id' => 20, 'chat' => { 'id' => chat_id },
                       'from' => { 'id' => from }, 'text' => text,
                       'reply_to_message' => { 'message_id' => prompt_id } } }
    end

    it 'asks for the correction with a forced reply' do
      expect(telegram.sent.last).to include(force_reply: true, reply_to: 300)
      expect(document.reload.edit_prompt_message_id).to be_present
    end

    it 'applies the reply and shows the suggestion again' do
      intake.handle(update: reply('local 120 mundial 30 data 2026-11-05'))

      expect(document.reload).to have_attributes(amount_cents: 15_000, congregation_cents: 12_000,
                                                 worldwide_cents: 3000, value_source: 'human',
                                                 document_date: Date.new(2026, 11, 5))
      expect(telegram.edits.last).to include(message_id: 300,
                                             text: include('2026-11-05 - R$ 150,00 - S-24'))
    end

    it 'explains unknown keys' do
      intake.handle(update: reply('preco 10'))

      expect(telegram.sent.last).to include(reply_to: 20, text: include('Campo desconhecido'))
    end

    it 'ignores replies from people who cannot confirm' do
      intake.handle(update: reply('local 1', from: 8))

      expect(document.reload.congregation_cents).to be_nil
    end
  end

  it 'retries stuck documents on the next update' do
    old = { account:, telegram_chat_id: chat_id, updated_at: 11.minutes.ago }
    stuck = factories.finance_documents.create(old.merge(state: 'received'))
    confirmed = factories.finance_documents.create(old.merge(state: 'confirmed'))

    intake.handle(update: { 'update_id' => 9 })

    expect(Finance::SuggestJob).to have_been_enqueued.with(stuck.id)
    expect(Finance::ArchiveJob).to have_been_enqueued.with(confirmed.id)
  end
end
