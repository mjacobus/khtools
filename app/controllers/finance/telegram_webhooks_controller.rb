# frozen_string_literal: true

module Finance
  # Receives Telegram updates for one account's finance bot.
  class TelegramWebhooksController < ApplicationController
    skip_before_action :require_authorization
    skip_before_action :set_current
    skip_forgery_protection

    def create
      account = Db::Account.find_by(id: params[:account_id])
      return head :not_found unless account&.finance_enabled?
      return head :unauthorized unless valid_secret?(account)

      Intake.new(account:).call(update: JSON.parse(request.raw_post))
      head :ok
    rescue StandardError => exception
      # Telegram retries failed deliveries forever; stuck items are retried by Intake instead.
      ErrorHandler.new.notify_error(exception)
      head :ok
    end

    private

    def valid_secret?(account)
      expected = account.finance_telegram_webhook_secret.to_s
      given = request.headers['X-Telegram-Bot-Api-Secret-Token'].to_s
      expected.present? && ActiveSupport::SecurityUtils.secure_compare(given, expected)
    end
  end
end
