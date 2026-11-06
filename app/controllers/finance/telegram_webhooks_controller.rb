# frozen_string_literal: true

module Finance
  # Receives Telegram updates for one account's finance bot.
  class TelegramWebhooksController < ApplicationController
    skip_before_action :require_authorization
    skip_before_action :set_current
    skip_forgery_protection

    def create
      if !account&.finance_enabled?
        head :not_found
      elsif valid_secret?
        process_update
        head :ok
      else
        head :unauthorized
      end
    end

    private

    def process_update
      Intake.new(account:).call(update: JSON.parse(request.raw_post))
    rescue StandardError => exception
      # Telegram retries failed deliveries forever; stuck items are retried by Intake instead.
      ErrorHandler.new.notify_error(exception)
    end

    def account
      @account ||= Db::Account.find_by(id: params[:account_id])
    end

    def valid_secret?
      expected = account.finance_telegram_webhook_secret.to_s
      given = request.headers['X-Telegram-Bot-Api-Secret-Token'].to_s
      expected.present? && ActiveSupport::SecurityUtils.secure_compare(given, expected)
    end
  end
end
