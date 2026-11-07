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

    expect(page.css('h2').map(&:text)).to eq(%w[S-24 S-26])
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

    expect(page.css('h2')).to be_empty
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

    expect(page.at('h2').text.strip).to eq('Não identificados')
  end

  it 'shows where the documents not archived yet stand' do
    document(kind: 's26', state: 'suggested')

    get '/finance/documents', params: { month: '2026-09' }

    expect(page.at('.badge').text).to eq('aguardando confirmação')
  end

  context 'without access' do
    let(:access) { false }

    it 'is denied' do
      get '/finance/documents'

      expect(response).to redirect_to('/')
    end
  end
end
