# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::SuggestJob do
  let(:account) do
    factories.accounts.create.tap do |account|
      account.update!(finance_telegram_bot_token: 'token', anthropic_api_key: 'key',
                      finance_statement_password: 'senha')
    end
  end
  let(:telegram) { FakeTelegram.new }
  let(:reader) { instance_double(Finance::ReceiptReader) }
  let(:s24_result) do
    Finance::ReceiptReader::Result.new(is_s24: true, date: '2026-11-04',
                                       congregation_cents: 12_000, worldwide_cents: 3000)
  end

  before do
    telegram.files['f1'] = 'photo-bytes'
    allow(Telegram::Client).to receive(:new).with(token: 'token').and_return(telegram)
    allow(Finance::ReceiptReader).to receive(:new).with(api_key: 'key').and_return(reader)
  end

  after { FileUtils.rm_rf(Rails.root.join('storage/finance')) }

  def received(attributes = {})
    factories.finance_documents.create({ account:, telegram_message_id: 10, telegram_file_id: 'f1',
                                         mime_type: 'image/jpeg' }.merge(attributes))
  end

  def run(document)
    described_class.perform_now(document.id)
    document.reload
  end

  it 'reads an S-24 photo, replies with the suggestion and keeps the original locally' do
    allow(reader).to receive(:call)
      .with(image_bytes: 'photo-bytes', mime_type: 'image/jpeg').and_return(s24_result)

    document = run(received)

    expect(document).to have_attributes(state: 'suggested', kind: 's24', competence: '2026-11',
                                        amount_cents: 15_000, value_source: 'ai',
                                        bot_message_id: 501)
    expect(document.sha256).to eq(Digest::SHA256.hexdigest('photo-bytes'))
    expect(telegram.sent.last).to include(reply_to: 10,
                                          text: start_with('2026-11-04 - R$ 150,00 - S-24.jpg'))
    expect(File.binread(document.local_path)).to eq('photo-bytes')
  end

  it 'still suggests when the AI fails, asking for a correction' do
    allow(reader).to receive(:call).and_return(nil)

    document = run(received)

    expect(document).to have_attributes(state: 'suggested', kind: 's24', amount_cents: nil)
    expect(telegram.sent.last[:text]).to include('use ✏️ Corrigir')
  end

  it 'flags a duplicate file instead of suggesting it again' do
    telegram.files['f2'] = 'same'
    received(telegram_message_id: 9, telegram_file_id: 'f0',
             sha256: Digest::SHA256.hexdigest('same'), state: 'archived',
             drive_url: 'https://drive/x')

    document = run(received(telegram_file_id: 'f2'))

    expect(document.state).to eq('discarded')
    expect(telegram.sent.last).to include(reply_to: 10, text: 'Este arquivo já foi arquivado: https://drive/x')
  end

  it 'does nothing for documents already past received' do
    document = run(received(state: 'suggested'))

    expect(telegram.sent).to be_empty
    expect(document.state).to eq('suggested')
  end

  context 'with PDFs' do
    before do
      missing = %w[qpdf pdftotext].reject { |bin| system('which', bin, out: File::NULL) }
      skip("install poppler-utils and qpdf to run (missing: #{missing.join(', ')})") if missing.any?
    end

    let(:receipt_pdf) do
      finance_pdf('Comprovante de transação Pix', 'Dados do recebedor', 'Nome: AGUA EXEMPLO SA',
                  'Dados do pagamento', 'Valor: 74.49', 'Data: 05/10/2026')
    end

    def encrypted(bytes, password)
      Dir.mktmpdir do |dir|
        File.binwrite("#{dir}/in.pdf", bytes)
        system('qpdf', '--encrypt', password, password, '256', '--',
               "#{dir}/in.pdf", "#{dir}/out.pdf", exception: true)
        File.binread("#{dir}/out.pdf")
      end
    end

    def owner_only(bytes)
      Dir.mktmpdir do |dir|
        File.binwrite("#{dir}/in.pdf", bytes)
        system('qpdf', '--encrypt', '', 'owner', '256', '--', "#{dir}/in.pdf", "#{dir}/out.pdf",
               exception: true)
        File.binread("#{dir}/out.pdf")
      end
    end

    def pdf_document
      received(mime_type: 'application/pdf', original_filename: 'comprovante.pdf')
    end

    it 'classifies by rules' do
      telegram.files['f1'] = receipt_pdf

      document = run(pdf_document)

      expect(document).to have_attributes(kind: 'payment_receipt', amount_cents: 7449,
                                          value_source: 'rules', competence: '2026-10',
                                          document_date: Date.new(2026, 10, 5))
    end

    it 'opens encrypted PDFs with the account password' do
      telegram.files['f1'] = encrypted(receipt_pdf, 'senha')

      document = run(pdf_document)

      expect(document).to have_attributes(kind: 'payment_receipt', flags: 'decryptable')
    end

    it 'reads PDFs that only have an owner password (print/copy limits) without any password' do
      account.update!(finance_statement_password: '')
      telegram.files['f1'] = owner_only(receipt_pdf)

      document = run(pdf_document)

      expect(document).to have_attributes(kind: 'payment_receipt', amount_cents: 7449, flags: nil)
    end

    it 'flags encrypted PDFs it cannot open and warns' do
      telegram.files['f1'] = encrypted(receipt_pdf, 'outra')

      document = run(pdf_document)

      expect(document).to have_attributes(state: 'suggested', kind: 'statement',
                                          flags: 'encrypted_original')
      expect(telegram.sent.last[:text]).to include('⚠️ PDF com senha: não consegui abrir')
    end
  end
end
