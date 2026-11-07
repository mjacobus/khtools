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

  it "lists the month's documents by type, linking to Drive" do
    document(kind: 's26', drive_url: 'https://drive/s26')
    document(kind: 's24', document_date: Date.new(2026, 9, 2), amount_cents: 22_000,
             drive_url: 'https://drive/s24')

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.css('[data-kind] h2').map { |h2| h2.text.strip }).to eq(%w[S-24 S-26])
    expect(page.at('a[href="https://drive/s24"]').text).to eq('2026-09-02 - R$ 220,00 - S-24.jpg')
    expect(response.body).to include('02/09/2026', 'R$ 220,00')
  end

  it 'names files found by the backfill as they are called in Drive' do
    document(flags: 'backfill', original_filename: 'Recibo velho.jpg', telegram_message_id: nil,
             telegram_chat_id: nil, telegram_file_id: nil, drive_url: 'https://drive/old')

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.at('a[href="https://drive/old"]').text).to eq('Recibo velho.jpg')
  end

  it 'leaves out other months, other accounts and discarded files' do
    document(kind: 's26', original_filename: 'outro-mes.pdf', competence: '2026-08')
    document(kind: 's30', state: 'discarded')
    factories.finance_documents.create(competence: '2026-09', kind: 'bill')

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.css('[data-kind] h2')).to be_empty
  end

  it 'opens on the latest month with documents and offers the others' do
    document(competence: '2026-08')
    document(competence: '2026-10')

    get '/finance/documents'

    expect(page.at('select#month option[selected]')['value']).to eq('2026-10')
    expect(page.css('select#month option').pluck('value')).to eq(%w[2026-10 2026-08])
  end

  it 'calls out the files it could not tell the type of' do
    document(kind: 'unknown')

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.at('[data-kind] h2').text.strip).to eq('Não identificados')
  end

  it 'shows where the documents not archived yet stand' do
    document(kind: 's26', state: 'suggested')

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.at('li .badge').text).to eq('aguardando confirmação')
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

  describe 'cash of an S-24' do
    let(:telegram) { FakeTelegram.new }
    let(:s24) do
      document(kind: 's24', drive_url: 'https://drive/s24', cash_holder_name: 'Bia',
               cash_message_id: 900)
    end

    before { allow(Telegram::Client).to receive(:new).and_return(telegram) }

    it 'shows who holds it' do
      s24

      get '/finance/documents', params: { month: '2026-09' }

      expect(page.at('li .badge').text).to eq('💵 com Bia')
    end

    it 'marks it received and updates the message in the group' do
      post "/finance/documents/#{s24.id}/cash_received"

      expect(s24.reload).to have_attributes(cash_received_by: current_user.name,
                                            cash_received_at: be_present)
      expect(telegram.edits.last).to include(message_id: 900, buttons: nil)
      expect(response).to redirect_to('/finance/documents?month=2026-09')
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
