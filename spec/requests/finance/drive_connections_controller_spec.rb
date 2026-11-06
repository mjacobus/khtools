# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::DriveConnectionsController do
  let(:access) { true }
  let(:drive) { instance_double(GoogleDrive::Client, exchange_code: nil) }

  before do
    allow(GoogleDrive::Client).to receive(:new).and_return(drive)
    grant_access(current_user) if access
    current_user.save!
  end

  def signed_state(account_id)
    Rails.application.message_verifier(:finance_drive).generate(account_id, expires_in: 1.hour)
  end

  it 'shows the connection status with a Google consent link' do
    get '/finance/drive_connection'

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Conectar Drive da congregação', 'accounts.google.com',
                                     'access_type=offline', 'prompt=consent',
                                     CGI.escape('https://www.googleapis.com/auth/drive'))
  end

  it 'stores the refresh token for the signed account' do
    allow(drive).to receive(:exchange_code)
      .with(hash_including(code: 'CODE', redirect_uri: 'http://www.example.com/finance/drive_connection/callback'))
      .and_return('REFRESH')

    get '/finance/drive_connection/callback',
        params: { code: 'CODE', state: signed_state(current_account.id) }

    expect(current_account.reload.finance_google_refresh_token).to eq('REFRESH')
    follow_redirect!
    expect(response.body).to include('Drive conectado')
  end

  it 'rejects a bad state' do
    get '/finance/drive_connection/callback', params: { code: 'CODE', state: 'forged' }

    expect(response).to have_http_status(:bad_request)
    expect(drive).not_to have_received(:exchange_code)
  end

  it 'rejects a state signed for another account' do
    other = factories.accounts.create

    get '/finance/drive_connection/callback',
        params: { code: 'CODE', state: signed_state(other.id) }

    expect(response).to have_http_status(:bad_request)
    expect(drive).not_to have_received(:exchange_code)
  end

  it 'explains when the Google consent was cancelled' do
    get '/finance/drive_connection/callback',
        params: { error: 'access_denied', state: signed_state(current_account.id) }

    expect(response).to redirect_to('/finance/drive_connection')
    expect(drive).not_to have_received(:exchange_code)
  end

  context 'without access' do
    let(:access) { false }

    it 'is denied' do
      get '/finance/drive_connection'

      expect(response).to redirect_to('/')
    end
  end
end
