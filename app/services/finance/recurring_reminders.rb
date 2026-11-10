# frozen_string_literal: true

module Finance
  # Every morning, in the finance group: the monthly reminders whose day came and that are not
  # marked done yet (Contas › Documentos › Lembretes).
  class RecurringReminders
    TITLE = '🔔 Lembretes'
    FOOTER = 'Marque como feito em Contas › Documentos › Lembretes.'

    def initialize(account:, telegram:)
      @account = account
      @telegram = telegram
    end

    def remind(today: Date.current)
      pending = @account.finance_reminders.order(:day, :id)
        .select { |reminder| reminder.pending?(today) }
      if pending.any?
        lines = pending.map { |reminder| "• #{reminder.title} (dia #{reminder.day})" }
        @telegram.send_message(chat_id: @account.finance_telegram_chat_id,
                               text: [TITLE, *lines, FOOTER].join("\n"))
      end
    end
  end
end
