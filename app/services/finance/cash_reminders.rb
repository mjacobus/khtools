# frozen_string_literal: true

module Finance
  # Daily nudge to whoever still holds the cash of a past meeting, mentioning them so Telegram
  # notifies them, until the treasurer taps "Recebi".
  class CashReminders
    def initialize(account:, telegram:)
      @account = account
      @telegram = telegram
    end

    def remind(today: Date.current)
      pending = @account.finance_documents
        .where(kind: 's24', state: 'archived', cash_received_at: nil, document_date: ...today)
        .where.not(cash_holder_name: nil).order(:document_date)
      if pending.any?
        @telegram.send_message(chat_id: @account.finance_telegram_chat_id, html: true,
                               text: ['💵 Dinheiro a entregar a quem cuida das contas',
                                      *pending.map { |document| line(document) }].join("\n"))
      end
    end

    private

    def line(document)
      date = document.document_date
      "• #{Messages::WEEKDAYS[date.wday]} #{date.strftime('%d/%m')} · " \
        "#{Money.format(cents: document.amount_cents.to_i)} · com #{holder(document)}"
    end

    def holder(document)
      name = CGI.escapeHTML(document.cash_holder_name)
      if document.cash_holder_telegram_id
        %(<a href="tg://user?id=#{document.cash_holder_telegram_id}">#{name}</a>)
      else
        name
      end
    end
  end
end
