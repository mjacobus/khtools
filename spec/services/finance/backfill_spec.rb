# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::Backfill do
  let(:account) { factories.accounts.create(finance_drive_root_folder_id: 'ROOT') }
  let(:expected_report) do
    {
      'Arquivo Corrente/2026-09/2026-09-02 R$220 Recibo Donativos .jpg' => 'new',
      'Arquivo Corrente/2026-09/Folha de Contas (S-26) __ Contas __ JW Hub.pdf' => 'new',
      'Arquivo Corrente/2026-09/Organizar/comprovantePix.pdf' => 'new',
      'Arquivo Corrente/solto.pdf' => 'ignored',
      'Arquivo das contas/2025-10/20251031 - 1.600 - Pix Betel.pdf' => 'new',
      'Arquivo das contas/Documentos permanentes' => 'ignored',
      'Aprovações permanentes' => 'ignored'
    }
  end
  let(:drive) { instance_double(GoogleDrive::Client) }
  let(:backfill) { described_class.new(account:, drive:) }
  let(:tree) do
    {
      'ROOT' => [folder('CUR', 'Arquivo Corrente'), folder('OLD', 'Arquivo das contas'),
                 folder('PERM', 'Aprovações permanentes')],
      'CUR' => [folder('M1', '2026-09'), file('LOOSE', 'solto.pdf')],
      'M1' => [file('A', '2026-09-02 R$220 Recibo Donativos .jpg', mime_type: 'image/jpeg'),
               file('B', 'Folha de Contas (S-26) __ Contas __ JW Hub.pdf'),
               folder('SUB', 'Organizar')],
      'SUB' => [file('C', 'comprovantePix.pdf')],
      'OLD' => [folder('M2', '2025-10'), folder('KEEP', 'Documentos permanentes')],
      'M2' => [file('D', '20251031 - 1.600 - Pix Betel.pdf')],
      'KEEP' => [file('E', 'Declaração.pdf')],
      'PERM' => [file('F', 'Acordo.pdf')]
    }
  end

  before do
    allow(drive).to receive(:children) { |parent_id:| tree.fetch(parent_id) }
  end

  def folder(id, name)
    { id:, name:, folder: true, mime_type: GoogleDrive::Client::FOLDER, sha256: nil,
      web_view_link: nil }
  end

  def file(id, name, mime_type: 'application/pdf')
    { id:, name:, folder: false, mime_type:, sha256: "sha-#{id}", web_view_link: "https://drive/#{id}" }
  end

  def statuses(report)
    report.to_h { |row| [row.path, row.status] }
  end

  def registered(drive_file_id)
    account.finance_documents.find_by(drive_file_id:)
  end

  it 'reports what it would register without touching the database' do
    report = backfill.run(apply: false)

    expect(statuses(report)).to eq(expected_report)
    expect(account.finance_documents.count).to eq(0)
  end

  it 'registers each file as an archived document, flagged as backfilled' do
    backfill.run(apply: true)

    expect(registered('A')).to be_backfilled
    expect(registered('A')).to have_attributes(
      state: 'archived', kind: 's24', competence: '2026-09', document_date: Date.new(2026, 9, 2),
      amount_cents: 22_000, original_filename: '2026-09-02 R$220 Recibo Donativos .jpg',
      mime_type: 'image/jpeg', sha256: 'sha-A', drive_url: 'https://drive/A',
      telegram_message_id: nil
    )
  end

  it 'takes the month from the folder, also for files in its subfolders' do
    backfill.run(apply: true)

    expect(registered('D')).to have_attributes(kind: 'remittance_receipt', competence: '2025-10',
                                               document_date: Date.new(2025, 10, 31),
                                               amount_cents: 160_000)
    expect(registered('C')).to have_attributes(competence: '2026-09')
  end

  it 'skips files registered before, so it can run again' do
    backfill.run(apply: true)

    report = backfill.run(apply: true)

    expect(report.map(&:status).uniq).to contain_exactly('known', 'ignored')
    expect(account.finance_documents.count).to eq(4)
  end

  describe 'reading the file name' do
    def read(attribute, expected)
      expected.keys.index_with do |name|
        described_class::Name.new(name, competence: '2026-03').public_send(attribute)
      end
    end

    def kinds # rubocop:disable Metrics/MethodLength -- one row per naming style seen in the archive
      {
        'Auditoria de Contas - 2025-09 - 2025-11.pdf' => 'audit_report',
        'Carta de Agradecimento - Março de 2025 – ATV.pdf' => 'thank_you_letter',
        '2025-05-31 - S-26.pdf' => 's26',
        'Relatório mensal de contas da congregação (S-30) __ Contas __ JW Hub.pdf' => 's30',
        '2026-05-01 - Registro de Transferência de Fundos (TO-62).pdf' => 'remittance_record',
        'Extrato da Conta da Congregação em Betel - Maio de 2026.pdf' => 'betel_statement',
        '2024-03-01 - Extrato_Betel_Marco.pdf' => 'betel_statement',
        'extrato conta corrente abril.pdf' => 'statement',
        '2025-04-30 - 1.510 - Remessa Betel Abril.pdf' => 'remittance_receipt',
        '2025-03-05 - 300 - Recibo Donativo.jpeg' => 's24',
        '2026-07-07 R$63,43 Comprovante Água Corsan .pdf' => 'payment_receipt',
        'Fatura RGE.pdf' => 'bill',
        'S-26_T Nov.23.pdf' => 's26',
        'S30_ABRIL (Site).pdf' => 's30',
        'Transação Testemunhas de Jeová Julho 2024.pdf' => 'remittance_record',
        '250815 - 95,13 - Bol. Luz.pdf' => 'bill',
        '2026-02-07 - R$2685,15 - NF9709 Tintas Dilkin.pdf' => 'bill',
        'Despesa Luz Fev 2024.jpeg' => 'payment_receipt',
        '2026-02-28 - R$235,30 - Cupom Dilkin Diluente e Esmalte.jpg' => 'payment_receipt',
        'Depósito 219 08.04.jpeg' => 'payment_receipt',
        'Água Julho.jpeg' => 'payment_receipt',
        '2026-03-18 - R$ 67,46 - Corsan (fev).pdf' => 'payment_receipt',
        '2024-11-06 - 385.jpg' => 's24',
        '2024-11-11 - 49,79.jpg' => 'unknown',
        'Invest Fácil.docx' => 'unknown'
      }
    end

    def amounts
      {
        '2026-07-08 R$3.825,00 -Transações (saque).pdf' => 382_500,
        '2026-05-02 - R$ 140,00 - s24.jpg' => 14_000,
        '20250930 - 1.600 - Pix Betel.pdf' => 160_000,
        '2025-03-24 - 288,53 - Pix Super.jpeg' => 28_853,
        'Fatura RGE.pdf' => nil
      }
    end

    def dates
      {
        '2026-09-02 R$220 Recibo.jpg' => Date.new(2026, 9, 2),
        '20251031 - Remessa Betel.pdf' => Date.new(2025, 10, 31),
        '30112025 - 1472 - Remessa Betel.pdf' => Date.new(2025, 11, 30),
        '250809 - 205 - Reembolso.pdf' => Date.new(2025, 8, 9),
        '300126 - 282,14 - Zoom.jpg' => Date.new(2026, 1, 30),
        '07.03 - Andaimes.jpeg' => Date.new(2026, 3, 7),
        '2024-11-31 - Carta.pdf' => nil,
        'Fatura RGE.pdf' => nil
      }
    end

    it 'tells the kind' do
      expect(read(:kind, kinds)).to eq(kinds)
    end

    it 'reads the date in the formats used over the years' do
      expect(read(:date, dates)).to eq(dates)
    end

    it 'reads the amount' do
      expect(read(:amount_cents, amounts)).to eq(amounts)
    end
  end
end
