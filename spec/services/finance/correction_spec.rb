# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::Correction do
  let(:document) do
    Db::FinanceDocument.new(kind: 's24', document_date: Date.new(2026, 11, 4),
                            competence: '2026-11')
  end

  def apply(text)
    described_class.apply(document:, text:)
  end

  it 'sets S-24 values and their sum' do
    apply('local 120 mundial 30 data 2026-11-05')

    expect(document).to have_attributes(congregation_cents: 12_000, worldwide_cents: 3000,
                                        amount_cents: 15_000, document_date: Date.new(2026, 11, 5),
                                        value_source: 'human')
  end

  it 'fixes the total written on the S-24, which only feeds the mismatch warning' do
    apply('total 213,10')

    expect(document).to have_attributes(written_total_cents: 21_310, amount_cents: nil)
  end

  it 'accepts Portuguese type labels, Brazilian dates and a free description' do
    apply('tipo comprovante valor 104,33 data 26/10/2026 desc RGE luz')

    expect(document).to have_attributes(kind: 'payment_receipt', amount_cents: 10_433,
                                        document_date: Date.new(2026, 10, 26),
                                        description: 'RGE luz', competence: '2026-10')
  end

  it 'accepts multi-word labels' do
    apply('tipo Remessa Betel TO-62 data 2026-11-02')

    expect(document).to have_attributes(kind: 'remittance_record', competence: '2026-10',
                                        document_date: Date.new(2026, 10, 31))
  end

  it 'lets the month be set explicitly' do
    apply('mes 2026-09 data 2026-10-01')

    expect(document.competence).to eq('2026-09')
  end

  it 'rejects unknown keys listing the valid ones' do
    expect do
      apply('preco 10')
    end.to raise_error(described_class::Error,
                       /tipo, data, valor, local, mundial, total, mes, desc/)
  end

  it 'rejects bad values' do
    expect { apply('data ontem') }.to raise_error(described_class::Error, /data/)
    expect { apply('valor abc') }.to raise_error(described_class::Error, /valor/)
    expect { apply('tipo boleto-x') }.to raise_error(described_class::Error, /tipo/)
    expect { apply('mes 2026') }.to raise_error(described_class::Error, /mes/)
  end
end
