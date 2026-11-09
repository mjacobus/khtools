# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::CorrectionJob do
  let(:telegram) { FakeTelegram.new }
  let(:assistant) { instance_double(Finance::CorrectionAssistant) }
  let(:account) do
    factories.accounts.create.tap do |account|
      account.update!(finance_telegram_chat_id: '-100555', finance_confirmer_telegram_ids: '42',
                      ai_api_key: 'key')
    end
  end
  let(:document) do
    factories.finance_documents.create(account:, telegram_chat_id: -100_555, state: 'suggested',
                                       kind: 'unknown', competence: '2026-06', bot_message_id: 300)
  end
  let(:voice) do
    { 'message_id' => 20, 'chat' => { 'id' => -100_555 },
      'from' => { 'id' => 42, 'first_name' => 'Ana' },
      'voice' => { 'file_id' => 'V1', 'mime_type' => 'audio/ogg' } }
  end

  before do
    allow(Telegram::Client).to receive(:new).and_return(telegram)
    allow(Finance::CorrectionAssistant).to receive(:new).with(api_key: 'key').and_return(assistant)
    telegram.files['V1'] = 'ogg-bytes'
    allow(assistant).to receive(:transcribe).with(audio: 'ogg-bytes')
      .and_return('auditoria de março a maio')
    allow(assistant).to receive(:correction).and_return('tipo audit_report mes 2026-05')
  end

  it 'corrects the document from a voice message' do
    described_class.perform_now(document.id, voice)

    expect(document.reload).to have_attributes(kind: 'audit_report', competence: '2026-05')
    expect(telegram.sent.last).to include(
      reply_to: 20,
      text: "✏️ Corrigido.\n🎤 auditoria de março a maio → tipo audit_report mes 2026-05\n" \
            'Confira a sugestão acima e confirme.'
    )
  end

  it 'keeps what was heard in the history' do
    described_class.perform_now(document.id, voice)

    expect(document.reload.corrections.last['text'])
      .to eq('🎤 auditoria de março a maio → tipo audit_report mes 2026-05')
  end

  it 'understands typed sentences too' do
    described_class.perform_now(document.id,
                                voice.except('voice').merge('text' => 'auditoria de mar-mai'))

    expect(assistant).to have_received(:correction).with(text: 'auditoria de mar-mai', document:)
    expect(document.reload.corrections.last['text'])
      .to eq('auditoria de mar-mai → tipo audit_report mes 2026-05')
  end

  it 'replies with what went wrong' do
    allow(assistant).to receive(:correction).and_raise(Finance::Correction::Error, 'Não entendi')

    described_class.perform_now(document.id, voice)

    expect(telegram.sent.last).to include(reply_to: 20, text: 'Não entendi')
    expect(document.reload.kind).to eq('unknown')
  end
end
