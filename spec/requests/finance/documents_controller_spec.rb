# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::DocumentsController do
  let(:access) { true }

  before do
    grant_access(current_user) if access
    current_user.save!
  end

  def document(**attributes)
    factories.finance_documents.create(account: current_account, state: 'archived',
                                       competence: '2026-09', **attributes)
  end

  def page
    Nokogiri::HTML(response.body)
  end

  def kinds
    page.css('#documents tbody .kind-label').map { |label| label.text.strip }
  end

  it "lists the month's documents by date, with their type, linking to Drive" do
    document(kind: 's26', document_date: Date.new(2026, 9, 10), drive_url: 'https://drive/s26')
    document(kind: 's24', document_date: Date.new(2026, 9, 2), amount_cents: 22_000,
             drive_url: 'https://drive/s24')

    get '/finance/documents', params: { month: '2026-09' }

    expect(kinds).to eq(%w[S-24 S-26])
    link = page.at('a[href="https://drive/s24"]')
    expect(link.text.strip).to eq('S-24')
    expect(link['title']).to eq('2026-09-02 - R$ 220,00 - S-24.jpg')
    expect(response.body).to include('02/09/2026', 'R$ 220,00')
  end

  it 'has no file name column: the type links to the file' do
    document(kind: 's26')

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.css('#documents thead th').map { |th| th.text.strip })
      .to eq(%w[Data Tipo Valor Ações])
  end

  it 'offers the month view and the all documents view as tabs' do
    get '/finance/documents', params: { view: 'all' }

    tabs = page.css('#document-tabs a')
    expect(tabs.map { |tab| tab.text.squish }).to eq(['Por período', 'Todos', 'Lembretes'])
    expect(page.at('#document-tabs a.active').text.squish).to eq('Todos')
  end

  it 'lists the documents of every month, newest first, with their month' do
    document(kind: 'audit_report', competence: '2025-11', document_date: Date.new(2025, 12, 3))
    document(kind: 'audit_report', competence: '2026-05', document_date: Date.new(2026, 6, 2))
    document(kind: 's24', competence: '2026-05', document_date: Date.new(2026, 5, 2))

    get '/finance/documents', params: { view: 'all', kind: 'audit_report' }

    expect(page.css('#documents tbody td.month').map { |cell| cell.text.strip })
      .to eq(%w[2026-05 2025-11])
    expect(page.at('select#month')).to be_nil
  end

  it 'shows on a history icon who sent each document and who confirmed it, and when' do
    document(kind: 's26', sent_by_name: 'Ana', created_at: Time.zone.local(2026, 9, 5, 14, 30),
             confirmed_by: 'Marcelo', confirmed_at: Time.zone.local(2026, 9, 6, 10, 0),
             document_date: Date.new(2026, 9, 1))
    document(kind: 's30', flags: 'backfill', telegram_message_id: nil,
             document_date: Date.new(2026, 9, 2))

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.css('#documents tbody a.history').pluck('title')).to eq(
      ["Enviado por Ana em 05/09/2026 às 14:30\nConfirmado por Marcelo em 06/09/2026 às 10:00",
       'Já estava no Drive']
    )
  end

  it 'counts on the reminders tab the audits still to do' do
    document(kind: 's24', competence: '2025-09')

    travel_to(Date.new(2025, 12, 10)) { get '/finance/documents' }

    expect(page.at('#document-tabs a[href*="reminders"] .badge').text).to eq('1')
  end

  it 'has a reminders tab with what to do and the rules' do
    get '/finance/documents', params: { view: 'reminders' }

    expect(page.at('#document-tabs a.active').text.squish).to eq('Lembretes')
    expect(page.css('#reminders-rules li').size).to be >= 3
    expect(page.at('#documents')).to be_nil
  end

  it 'names files found by the backfill as they are called in Drive' do
    document(flags: 'backfill', original_filename: 'Recibo velho.jpg', telegram_message_id: nil,
             telegram_chat_id: nil, telegram_file_id: nil, drive_url: 'https://drive/old')

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.at('a[href="https://drive/old"]')['title']).to eq('Recibo velho.jpg')
  end

  it 'leaves out other months, other accounts and discarded files' do
    document(kind: 's26', original_filename: 'outro-mes.pdf', competence: '2026-08')
    document(kind: 's30', state: 'discarded')
    factories.finance_documents.create(competence: '2026-09', kind: 'bill')

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.css('#documents tbody tr')).to be_empty
  end

  it "filters by type, offering the month's types" do
    document(kind: 's26', document_date: Date.new(2026, 9, 10))
    document(kind: 's24', document_date: Date.new(2026, 9, 2))
    document(kind: 's24', document_date: Date.new(2026, 9, 5))

    get '/finance/documents', params: { month: '2026-09', kind: 's24' }

    expect(kinds).to eq(%w[S-24 S-24])
    expect(page.css('select#kind option').map { |option| [option.text, option['value']] })
      .to eq([['Todos os tipos', ''], %w[S-24 s24], %w[S-26 s26]])
    expect(page.at('select#kind option[selected]')['value']).to eq('s24')
  end

  it 'searches the file names' do
    document(kind: 'bill', description: 'Luz', document_date: Date.new(2026, 9, 3))
    document(kind: 'bill', description: 'Agua', document_date: Date.new(2026, 9, 4))

    get '/finance/documents', params: { month: '2026-09', q: 'luz' }

    expect(page.css('#documents tbody tr').map { |row| row.text.squish })
      .to all(include('Luz'))
    expect(page.css('#documents tbody tr').size).to eq(1)
  end

  it 'opens on the latest month with documents and offers the others' do
    document(competence: '2026-08')
    document(competence: '2026-10')

    get '/finance/documents'

    expect(page.at('select#month option[selected]')['value']).to eq('2026-10')
    expect(page.css('select#month option').pluck('value')).to eq(%w[2026-10 2026-08])
  end

  it 'calls out the files it could not tell the type of, with their name' do
    document(kind: 'unknown', flags: 'backfill', original_filename: 'Anotações.docx')

    get '/finance/documents', params: { month: '2026-09' }

    expect(kinds).to eq(['Não identificado'])
    expect(page.at('#documents tbody .details').text.strip).to eq('Anotações')
  end

  it 'adds only the description to the type' do
    document(kind: 'bill', description: 'Água', drive_url: 'https://drive/agua')

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.at('#documents tbody .details').text.strip).to eq('Água')
  end

  it 'shows where the documents not archived yet stand' do
    document(kind: 's26', state: 'suggested')

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.at('#documents tbody .badge').text).to eq('aguardando confirmação')
  end

  it 'refreshes in place, keeping the scroll, after an action' do
    get '/finance/documents'

    expect(page.at('meta[name="turbo-refresh-method"]')['content']).to eq('morph')
    expect(page.at('meta[name="turbo-refresh-scroll"]')['content']).to eq('preserve')
  end

  it 'hides files deleted in Drive' do
    document(kind: 's26', deleted_at: Time.current, original_filename: 'apagado.pdf')

    get '/finance/documents', params: { month: '2026-09' }

    expect(response.body).not_to include('apagado')
  end

  it 'splits each S-24 and the S-24 total into worldwide work and local expenses' do
    document(kind: 's24', amount_cents: 16_000, worldwide_cents: 11_000, congregation_cents: 5000)
    document(kind: 's24', amount_cents: 10_000, worldwide_cents: 2000, congregation_cents: 8000)
    document(kind: 'bill', amount_cents: 5000)

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.at('#documents tfoot').text.squish)
      .to eq('Donativos (2 S-24) · Obra R$ 130,00 · Local R$ 130,00 · Total R$ 260,00')
    expect(page.css('#documents tbody .s24-split').map { |split| split.text.squish })
      .to contain_exactly('obra R$ 110,00 · local R$ 50,00', 'obra R$ 20,00 · local R$ 80,00')
  end

  describe 'cash of an S-24' do
    let(:telegram) { FakeTelegram.new }
    let(:s24) do
      document(kind: 's24', drive_url: 'https://drive/s24', cash_holder_name: 'Bia',
               cash_message_id: 900)
    end

    before { allow(Telegram::Client).to receive(:new).and_return(telegram) }

    it 'adds up the cash each person still holds, in any month' do
      document(kind: 's24', cash_holder_name: 'Bia', amount_cents: 10_000, competence: '2026-08')
      document(kind: 's24', cash_holder_name: 'Bia', amount_cents: 5_000)
      document(kind: 's24', cash_holder_name: 'Caio', amount_cents: 2_000)
      document(kind: 's24', cash_holder_name: 'Caio', amount_cents: 9_000,
               cash_received_at: Time.current)

      get '/finance/documents', params: { month: '2026-09' }

      expect(page.css('#cash-ledger li').map { |line| line.text.squish })
        .to eq(['Bia 2 S-24 R$ 150,00', 'Caio 1 S-24 R$ 20,00'])
    end

    it 'shows who holds it' do
      s24

      get '/finance/documents', params: { month: '2026-09' }

      expect(page.css('#documents tbody .pending-sign').pluck('title'))
        .to eq(['Dinheiro com Bia', 'Pix pendente'])
    end

    it 'marks it received and updates the message in the group' do
      post "/finance/documents/#{s24.id}/cash_received"

      expect(s24.reload).to have_attributes(cash_received_by: current_user.name,
                                            cash_received_at: be_present)
      expect(telegram.edits.last).to include(message_id: 900,
                                             text: a_string_including('Pix: pendente'))
      expect(response).to redirect_to('/finance/documents?month=2026-09')
    end

    context 'with an accounts servant or helper' do
      def treasurer(user)
        publisher = factories.publishers.create(account: current_account, user:)
        current_account.finance_telegram_members.create!(telegram_id: 50, name: 'Tesoureiro',
                                                         role: 'helper', publisher:)
      end

      it 'shows the Recebi button only to them' do
        treasurer(factories.users.create(account: current_account))
        s24

        get '/finance/documents', params: { month: '2026-09' }

        expect(page.css('button[title="Recebi o dinheiro"]')).to be_empty
      end

      it 'refuses anyone else' do
        treasurer(factories.users.create(account: current_account))

        post "/finance/documents/#{s24.id}/cash_received"

        expect(response).to have_http_status(:forbidden)
        expect(s24.reload.cash_received_at).to be_nil
      end

      it 'lets them mark it received' do
        treasurer(current_user)
        s24

        get '/finance/documents', params: { month: '2026-09' }

        expect(page.css('button[title="Recebi o dinheiro"]').size).to eq(1)
      end
    end

    it 'marks the Pix done and updates the message in the group' do
      post "/finance/documents/#{s24.id}/cash_pix"

      expect(s24.reload).to have_attributes(cash_pix_by: current_user.name, cash_pix_at: be_present)
      expect(telegram.edits.last).to include(message_id: 900,
                                             text: a_string_including('Pix: feito por'))
      expect(response).to redirect_to('/finance/documents?month=2026-09')
    end

    it 'shows the Pix is still to do' do
      s24

      get '/finance/documents', params: { month: '2026-09' }

      expect(page.css('#documents tbody .pending-sign').pluck('title')).to include('Pix pendente')
    end

    it 'says nothing once the cash arrived and the Pix is done' do
      s24.update!(cash_received_at: Time.current, cash_pix_at: Time.current)

      get '/finance/documents', params: { month: '2026-09' }

      expect(page.css('#documents tbody .pending-sign, #documents tbody .badge')).to be_empty
    end
  end

  describe 'editing' do
    let(:drive) { instance_double(GoogleDrive::Client) }
    let(:month_folder) { instance_double(Finance::MonthFolder, find_or_create: 'OCT') }
    let(:archived) do
      document(kind: 'unknown', flags: 'backfill', original_filename: 'Energia.pdf',
               drive_file_id: 'F1', drive_url: 'https://drive/F1', telegram_message_id: nil,
               telegram_chat_id: nil, telegram_file_id: nil)
    end

    before do
      allow(GoogleDrive::Client).to receive(:new).and_return(drive)
      allow(Finance::MonthFolder).to receive(:new).and_return(month_folder)
      allow(drive).to receive(:move).and_return(id: 'F1', web_view_link: 'https://drive/F1b')
    end

    def update(**fields)
      patch "/finance/documents/#{archived.id}",
            params: { document: { kind: 'bill', competence: '2026-10', document_date: '2026-10-05',
                                  amount: '74,12', description: 'Luz' }.merge(fields) }
    end

    it 'tells who sent, confirmed and corrected it' do
      archived.update!(sent_by_name: 'Ana', created_at: Time.zone.local(2026, 9, 2, 10),
                       confirmed_by: 'Marcelo', confirmed_at: Time.zone.local(2026, 9, 3, 9),
                       corrections: [{ 'at' => '2026-09-04T08:00:00-03:00', 'by_name' => 'Bia',
                                       'text' => 'tipo comprovante' }])

      get "/finance/documents/#{archived.id}/edit"

      expect(page.css('#history li').map { |item| item.text.squish }).to eq(
        ['Enviado por Ana em 02/09/2026 às 10:00', 'Confirmado por Marcelo em 03/09/2026 às 09:00',
         'Corrigido por Bia em 04/09/2026 às 08:00: tipo comprovante']
      )
    end

    it 'shows the form' do
      get "/finance/documents/#{archived.id}/edit"

      expect(page.at('select[name="document[kind]"] option[selected]')['value']).to eq('unknown')
    end

    it 'saves the changes and renames and moves the file in Drive' do
      update

      expect(archived.reload).to have_attributes(kind: 'bill', competence: '2026-10',
                                                 amount_cents: 7412, drive_url: 'https://drive/F1b')
      expect(drive).to have_received(:move).with(
        id: 'F1', name: '2026-10-05 - R$ 74,12 - Fatura Luz.pdf', parent_id: 'OCT',
        app_properties: hash_including(kind: 'bill', competence: '2026-10')
      )
      expect(response).to redirect_to('/finance/documents?month=2026-10')
    end

    it 'names the file by the new data from then on' do
      update

      expect(archived.reload.drive_name).to eq('2026-10-05 - R$ 74,12 - Fatura Luz.pdf')
      expect(archived.corrections.last).to include('by_name' => current_user.name)
    end

    it 'keeps everything as it was when Drive fails' do
      allow(drive).to receive(:move).and_raise(GoogleDrive::Client::Error, 'Drive HTTP 500')

      update

      expect(archived.reload.kind).to eq('unknown')
      expect(response.body).to include('Drive HTTP 500')
    end

    it 'refuses an invalid month without touching Drive' do
      update(competence: '2026-13')

      expect(response).to have_http_status(:unprocessable_entity)
      expect(drive).not_to have_received(:move)
    end
  end

  context 'without access' do
    let(:access) { false }

    it 'is denied' do
      get '/finance/documents'

      expect(response).to redirect_to('/')
    end
  end
end
