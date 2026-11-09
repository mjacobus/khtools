# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::Naming do
  def document(attributes)
    Db::FinanceDocument.new(attributes)
  end

  it 'names an S-24 photo' do
    doc = document(kind: 's24', document_date: Date.new(2026, 11, 4), amount_cents: 15_000,
                   mime_type: 'image/jpeg')

    expect(described_class.filename(document: doc)).to eq('2026-11-04 - R$ 150,00 - S-24.jpg')
  end

  it 'names a monthly statement by competence' do
    doc = document(kind: 'statement', competence: '2026-10', original_filename: 'x.pdf')

    expect(described_class.filename(document: doc)).to eq('2026-10 - Extrato.pdf')
  end

  it 'appends the description' do
    doc = document(kind: 'payment_receipt', document_date: Date.new(2026, 10, 26),
                   amount_cents: 10_433, description: 'RGE', mime_type: 'application/pdf')

    expect(described_class.filename(document: doc))
      .to eq('2026-10-26 - R$ 104,33 - Comprovante RGE.pdf')
  end

  it 'names a remittance on the last day of its competence' do
    competence = Finance::Competence.default_for(kind: 'remittance_record',
                                                 document_date: Date.new(2026, 11, 2), period: nil)
    doc = document(kind: 'remittance_record', competence:, amount_cents: 158_705,
                   document_date: Finance::Competence.remittance_date(competence:),
                   original_filename: 'Transações.PDF')

    expect(competence).to eq('2026-10')
    expect(described_class.filename(document: doc))
      .to eq('2026-10-31 - R$ 1.587,05 - Remessa Betel TO-62.pdf')
  end

  it 'omits the amount when unknown' do
    doc = document(kind: 'unknown', document_date: Date.new(2026, 11, 4), mime_type: 'image/png')

    expect(described_class.filename(document: doc)).to eq('2026-11-04 - Documento.jpg')
  end

  it 'gives the folder path' do
    expect(described_class.folder_path(document: document(competence: '2026-10')))
      .to eq(['Arquivo Corrente', '2026-10'])
  end

  describe '.short' do
    it 'drops the date, the amount and the extension, shown in their own columns' do
      expect(described_class.short('2026-09-02 - R$ 315,00 - S-24.jpg')).to eq('S-24')
      expect(described_class.short('2026-09-15 - R$ 74,12 - Fatura Água.pdf')).to eq('Fatura Água')
      expect(described_class.short('2026-09 - Extrato Betel.pdf')).to eq('Extrato Betel')
      expect(described_class.short('2026-09-09 R$250 Recibo Donativos.jpg')).to eq('Recibo Donativos')
      expect(described_class.short('20261227 - 77,90 - Pag. Água.pdf')).to eq('Pag. Água')
      expect(described_class.short('Fatura Energia.pdf')).to eq('Fatura Energia')
    end

    it 'keeps the name when nothing else is left' do
      expect(described_class.short('2026-09-02.jpg')).to eq('2026-09-02')
    end
  end
end
