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

    # The signed state must name the account of whoever finishes the flow, so a link
    # started by someone else can't attach this Google account to theirs.
    def callback
      unless state_for_current_account?
        return head :bad_request
      end
      if params[:error]
        return redirect_back_with(error: t('app.messages.finance_drive_cancelled'))
      end

      current_account.update!(finance_google_refresh_token: exchange_code)
      redirect_back_with(notice: t('app.messages.finance_drive_connected'))
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      head :bad_request
    end

    private

    def state_for_current_account?
      verifier.verify(params[:state].to_s) == current_account.id
    end

    def exchange_code
      GoogleDrive::Client.new(**oauth_client)
        .exchange_code(code: params[:code], redirect_uri: callback_url)
    end

    def redirect_back_with(flash)
      redirect_to finance_integration_path('drive'), flash:
    end

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
