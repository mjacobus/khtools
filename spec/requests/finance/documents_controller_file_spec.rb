# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::DocumentsController do
  let(:telegram) { FakeTelegram.new }
  let(:waiting) do
    factories.finance_documents.create(account: current_account, state: 'suggested',
                                       kind: 'statement', competence: '2026-09',
                                       mime_type: 'application/pdf', telegram_file_id: 'tg-file')
  end

  before do
    grant_access(current_user)
    current_user.save!
    allow(Telegram::Client).to receive(:new).and_return(telegram)
  end

  after { FileUtils.rm_f(waiting.local_path) }

  it 'links a document not in Drive yet to its file' do
    waiting
    get '/finance/documents', params: { month: '2026-09' }

    link = Nokogiri::HTML(response.body).at('td.kind a[target="_blank"]')
    expect(link['href']).to eq("/finance/documents/#{waiting.id}/file")
  end

  it 'shows the copy kept until it is archived' do
    waiting.store_local_copy('%PDF kept')

    get "/finance/documents/#{waiting.id}/file"

    expect(response.body).to eq('%PDF kept')
    expect(response.headers['Content-Type']).to eq('application/pdf')
    expect(response.headers['Content-Disposition']).to start_with('inline')
  end

  it 'downloads it again from Telegram when the copy is gone' do
    telegram.files['tg-file'] = '%PDF from telegram'

    get "/finance/documents/#{waiting.id}/file"

    expect(response.body).to eq('%PDF from telegram')
  end

  it 'does not show the files of another congregation' do
    other = factories.finance_documents.create(account: factories.accounts.create,
                                               state: 'suggested', kind: 'statement',
                                               telegram_file_id: 'x')

    get "/finance/documents/#{other.id}/file"

    expect(response).to have_http_status(:not_found)
  end
end
