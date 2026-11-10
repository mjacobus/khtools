# frozen_string_literal: true

module Finance
  # Every morning, in the finance group: the monthly reminders whose day came and that are not
  # done yet, each with a button to mark it done (handled by Intake).
  class RecurringReminders
    TITLE = '🔔 Lembretes'
    FOOTER = 'Toque no botão quando estiver feito.'

    def initialize(account:, telegram:)
      @account = account
      @telegram = telegram
    end

    def remind(today: Date.current)
      pending = pending(today)
      if pending.any?
        @telegram.send_message(chat_id: @account.finance_telegram_chat_id, text: text(pending),
                               buttons: buttons(pending), html: true)
      end
    end

    # After someone taps a button: what is still pending, and who did what.
    def update(message_id:, done:, today: Date.current)
      pending = pending(today)
      text = pending.any? ? text(pending) : TITLE
      @telegram.edit_message(chat_id: @account.finance_telegram_chat_id, message_id:,
                             text: "#{text}\n#{CGI.escapeHTML(done)}",
                             buttons: buttons(pending).presence, html: true)
    end

    private

    def pending(today)
      @account.finance_reminders.includes(responsible: :publisher).order(:day, :id)
        .select { |reminder| reminder.pending?(today) }
    end

    def text(pending)
      lines = pending.map do |reminder|
        "• #{CGI.escapeHTML(reminder.title)} (dia #{reminder.day})#{mention(reminder.responsible)}"
      end
      [TITLE, *lines, FOOTER].join("\n")
    end

    def mention(member)
      if member
        name = CGI.escapeHTML(member.display_name)
        %( · <a href="tg://user?id=#{member.telegram_id}">#{name}</a>)
      end
    end

    def buttons(pending)
      pending.map { |reminder| [["✅ #{reminder.title}", "fin:reminder_done:#{reminder.id}"]] }
    end
  end
end
