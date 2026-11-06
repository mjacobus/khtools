# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::Messages do
  def document(attributes = {})
    Db::FinanceDocument.new({ id: 9, kind: 's24', document_date: Date.new(2026, 11, 4),
                              competence: '2026-11', amount_cents: 15_000,
                              congregation_cents: 12_000, worldwide_cents: 3000,
                              value_source: 'ai', mime_type: 'image/jpeg' }.merge(attributes))
  end

  it 'suggests name, folder, S-24 split and origin with the three buttons' do
    text, buttons = described_class.suggestion(document:)

    expect(text).to eq("2026-11-04 - R$ 150,00 - S-24.jpg → Arquivo Corrente/2026-11/\n" \
                       "Congregação R$ 120,00 · Obra mundial R$ 30,00\n(lido por IA)")
    expect(buttons).to eq([[['✅ Confirmar', 'fin:confirm:9'], ['✏️ Corrigir', 'fin:edit:9'],
                            ['🗑️ Não é das contas', 'fin:discard:9']]])
  end

  it 'warns when the total written on the S-24 does not match its split' do
    text = described_class.suggestion(document: document(written_total_cents: 16_000)).first

    expect(text).to include('⚠️ Total escrito no recibo (R$ 160,00) ' \
                            'não confere com a soma (R$ 150,00)')
  end

  it 'does not warn when the written total matches or was not read' do
    matching = described_class.suggestion(document: document(written_total_cents: 15_000)).first
    unread = described_class.suggestion(document: document(written_total_cents: nil)).first

    expect(matching).not_to include('Total escrito')
    expect(unread).not_to include('Total escrito')
  end

  it 'warns when confirming replaces the file already archived for the month' do
    doc = document(kind: 's26', competence: '2026-09', mime_type: 'application/pdf')
    allow(doc).to receive(:replaced_document).and_return(document(id: 3))

    expect(described_class.suggestion(document: doc).first)
      .to include('⚠️ Substitui o arquivo já arquivado ' \
                  '(a versão anterior fica no histórico do Drive)')
  end

  it 'says the file was replaced' do
    expect(described_class.archived(document: document(drive_url: 'https://drive/x'),
                                    replaced: true))
      .to start_with('Substituído: <a href="https://drive/x">')
  end

  it 'labels the origin of rule-read and human values' do
    rules = described_class.suggestion(document: document(value_source: 'rules')).first
    human = described_class.suggestion(document: document(value_source: 'human')).first

    expect(rules).to include('(lido do PDF)')
    expect(human).to include('(informado)')
  end

  it 'warns about a PDF it could not open' do
    doc = document(kind: 'statement', flags: 'encrypted_original', value_source: nil,
                   mime_type: 'application/pdf')

    expect(described_class.suggestion(document: doc).first)
      .to include('⚠️ PDF com senha: não consegui abrir')
  end

  it 'asks for a correction when values or month are missing' do
    doc = document(amount_cents: nil, congregation_cents: nil, worldwide_cents: nil,
                   document_date: nil, competence: nil, value_source: nil)

    expect(described_class.suggestion(document: doc).first).to include('use ✏️ Corrigir')
  end

  it 'gives the duplicate notice with the archived file name as a link (HTML)' do
    expect(described_class.duplicate(original: document(drive_url: 'https://drive/x')))
      .to eq('Este arquivo já foi arquivado: ' \
             '<a href="https://drive/x">2026-11-04 - R$ 150,00 - S-24.jpg</a>')
  end

  it 'links the archived file name (HTML)' do
    expect(described_class.archived(document: document(drive_url: 'https://drive/x')))
      .to eq('Arquivado: <a href="https://drive/x">2026-11-04 - R$ 150,00 - S-24.jpg</a> ' \
             '→ Arquivo Corrente/2026-11/')
  end

  it 'escapes HTML in linked file names' do
    doc = document(kind: 'bill', description: 'Luz & <Água>', drive_url: 'https://drive/x?a=1&b=2')

    expect(described_class.archived(document: doc))
      .to include('<a href="https://drive/x?a=1&amp;b=2">', 'Luz &amp; &lt;Água&gt;')
  end
end
