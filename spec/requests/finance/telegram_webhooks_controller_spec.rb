# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Finance::TelegramWebhooksController do
  let(:skip_login) { true }
  let(:intake) { instance_double(Finance::Intake, handle: nil) }
  let(:account) do
    factories.accounts.create.tap do |account|
      account.update!(finance_telegram_bot_token: 'token', finance_telegram_chat_id: '-100',
                      finance_drive_root_folder_id: 'ROOT',
                      finance_telegram_webhook_secret: 'S3CRET')
    end
  end
  let(:update) do
    { 'update_id' => 1, 'message' => { 'message_id' => 2, 'chat' => { 'id' => -100 } } }
  end

  before { allow(Finance::Intake).to receive(:new).with(account:).and_return(intake) }

  def deliver(secret: 'S3CRET', account_id: account.id)
    post "/finance/telegram/#{account_id}", params: update.to_json,
                                            headers: { 'Content-Type' => 'application/json',
                                                       'X-Telegram-Bot-Api-Secret-Token' => secret }
  end

  it 'hands the update to the intake' do
    deliver

    expect(response).to have_http_status(:ok)
    expect(intake).to have_received(:handle).with(update: hash_including(update))
  end

  it 'rejects a wrong secret' do
    deliver(secret: 'nope')

    expect(response).to have_http_status(:unauthorized)
    expect(intake).not_to have_received(:handle)
  end

  it 'is not found for unknown or unconfigured accounts' do
    deliver(account_id: 0)
    expect(response).to have_http_status(:not_found)

    account.update!(finance_drive_root_folder_id: '')
    deliver
    expect(response).to have_http_status(:not_found)
  end

  it 'answers ok and reports when the intake fails, so Telegram does not retry forever' do
    allow(intake).to receive(:handle).and_raise('boom')
    allow(ErrorHandler).to receive(:new).and_return(instance_double(ErrorHandler,
                                                                    notify_error: nil))

    deliver

    expect(response).to have_http_status(:ok)
    expect(ErrorHandler.new).to have_received(:notify_error).with(an_instance_of(RuntimeError))
  end
end
