# frozen_string_literal: true

module Finance
  # Scheduled in config/recurring.yml, for every account with the bot on. Every morning: bring
  # in what changed in Drive, then remind the bills due soon, the monthly reminders and the
  # month's missing documents.
  # On meeting days, near the meeting ('meeting_day'): the missing S-24s and the cash to hand.
  class DailyJob < ApplicationJob
    def perform(part = 'morning')
      Db::Account.find_each do |account|
        if account.finance_enabled?
          public_send(part, account,
                      Telegram::Client.new(token: account.finance_telegram_bot_token))
        end
      rescue StandardError => exception
        ErrorHandler.new.notify_error(exception) # one account failing must not skip the others
      end
    end

    def morning(account, telegram)
      if account.finance_google_refresh_token.present?
        DriveSync.new(account:, drive: drive(account)).sync
      end
      BillReminders.new(account:, telegram:).remind
      RecurringReminders.new(account:, telegram:).remind
      ChecklistReminders.new(account:, telegram:).remind_month
    end

    def meeting_day(account, telegram)
      ChecklistReminders.new(account:, telegram:).remind_meetings
      CashReminders.new(account:, telegram:).remind
    end

    private

    def drive(account)
      GoogleDrive::Client.new(
        refresh_token: account.finance_google_refresh_token,
        client_id: Rails.application.credentials.dig(:oauth, :google, :key),
        client_secret: Rails.application.credentials.dig(:oauth, :google, :secret)
      )
    end
  end
end
