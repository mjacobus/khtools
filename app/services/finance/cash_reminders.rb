# frozen_string_literal: true

module Finance
  # Meeting-day nudge to whoever still holds the cash of a past meeting, mentioning them so Telegram
  # notifies them, until the treasurer taps "Recebi".
  class CashReminders
    def initialize(account:, telegram:)
      @account = account
      @telegram = telegram
    end

    def remind(today: Date.current)
      pending = @account.finance_documents.cash_pending.where(document_date: ...today)
        .order(:document_date)
      if pending.any?
        @telegram.send_message(chat_id: @account.finance_telegram_chat_id, html: true,
                               text: ["💵 Dinheiro a entregar a #{treasurer}",
                                      *pending.map { |document| line(document) }].join("\n"))
      end
    end

    private

    def line(document)
      date = document.document_date
      "• #{Messages::WEEKDAYS[date.wday]} #{date.strftime('%d/%m')} · " \
        "#{Money.format(cents: document.amount_cents.to_i)} · com #{holder(document)}"
    end

    def treasurer
      member = @account.finance_telegram_members.find_by(role: 'treasurer')
      if member
        mention(member.telegram_id, member.display_name)
      else
        'quem cuida das contas'
      end
    end

    def holder(document)
      mention(document.cash_holder_telegram_id, document.cash_holder_name)
    end

    def mention(telegram_id, name)
      if telegram_id
        %(<a href="tg://user?id=#{telegram_id}">#{CGI.escapeHTML(name)}</a>)
      else
        CGI.escapeHTML(name)
      end
    end
  end
end
