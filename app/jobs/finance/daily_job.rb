# frozen_string_literal: true

module Finance
  # Once a day (config/recurring.yml): bring in what changed in Drive, then remind the bills
  # due soon and what the month checklist is missing, for every account with the bot on.
  class DailyJob < ApplicationJob
    def perform
      Db::Account.find_each do |account|
        if account.finance_enabled?
          run(account)
        end
      rescue StandardError => exception
        ErrorHandler.new.notify_error(exception) # one account failing must not skip the others
      end
    end

    private

    def run(account)
      if account.finance_google_refresh_token.present?
        DriveSync.new(account:, drive: drive(account)).sync
      end
      telegram = Telegram::Client.new(token: account.finance_telegram_bot_token)
      BillReminders.new(account:, telegram:).remind
      ChecklistReminders.new(account:, telegram:).remind
    end

    def drive(account)
      GoogleDrive::Client.new(
        refresh_token: account.finance_google_refresh_token,
        client_id: Rails.application.credentials.dig(:oauth, :google, :key),
        client_secret: Rails.application.credentials.dig(:oauth, :google, :secret)
      )
    end
  end
end
