# frozen_string_literal: true

module Finance
  # Lets the congregation's Google account authorize khtools to write to its Drive.
  class DriveConnectionsController < ApplicationController
    AUTH_URL = 'https://accounts.google.com/o/oauth2/v2/auth'
    SCOPE = 'https://www.googleapis.com/auth/drive'

    def show
      @connected = current_account.finance_google_refresh_token.present?
      @authorize_url = "#{AUTH_URL}?#{authorize_params.to_query}"
    end

    def callback
      account = Db::Account.find(verifier.verify(params[:state].to_s))
      refresh_token = GoogleDrive::Client.exchange_code(code: params[:code],
                                                        redirect_uri: callback_url, **oauth_client)
      account.update!(finance_google_refresh_token: refresh_token)
      redirect_to finance_drive_connection_path, notice: t('app.messages.finance_drive_connected')
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      head :bad_request
    end

    private

    def authorize_params
      { client_id: oauth_client[:client_id], redirect_uri: callback_url, response_type: 'code',
        scope: SCOPE, access_type: 'offline', prompt: 'consent',
        state: verifier.generate(current_account.id, expires_in: 1.hour) }
    end

    def callback_url
      callback_finance_drive_connection_url
    end

    def verifier
      Rails.application.message_verifier(:finance_drive)
    end

    def oauth_client
      { client_id: Rails.application.credentials.dig(:oauth, :google, :key),
        client_secret: Rails.application.credentials.dig(:oauth, :google, :secret) }
    end
  end
end
