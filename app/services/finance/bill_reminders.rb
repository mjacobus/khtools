# frozen_string_literal: true

module Finance
  # Daily nudge in the finance group about bills due in the next days or already overdue.
  # Bills without a due date are never reminded (see FinanceDocument.open_bills).
  class BillReminders
    DAYS_AHEAD = 3
    TITLE = '⏰ Faturas em aberto'
    FOOTER = 'Marque como paga em Contas › Documentos.'

    def initialize(account:, telegram:)
      @account = account
      @telegram = telegram
    end

    def remind(today: Date.current)
      bills = @account.finance_documents.open_bills.where(due_date: ..(today + DAYS_AHEAD))
        .order(:due_date, :id).to_a
      if bills.any?
        lines = bills.map { |bill| "• #{title(bill)} · #{amount(bill)}#{due(bill, today)}" }
        @telegram.send_message(chat_id: @account.finance_telegram_chat_id,
                               text: [TITLE, *lines, FOOTER].join("\n"))
      end
    end

    private

    def title(bill)
      if bill.description.present?
        "#{Naming::LABELS.fetch('bill')} #{bill.description}"
      else
        File.basename(bill.drive_name.to_s, '.*')
      end
    end

    def amount(bill)
      bill.amount_cents && "#{Money.format(cents: bill.amount_cents)} · "
    end

    def due(bill, today)
      days = (bill.due_date - today).to_i
      date = bill.due_date.strftime('%d/%m')
      case days
      when ...0 then "vencida há #{-days} #{-days == 1 ? 'dia' : 'dias'} (#{date})"
      when 0 then "vence hoje (#{date})"
      when 1 then "vence amanhã (#{date})"
      else "vence em #{days} dias (#{date})"
      end
    end
  end
end
