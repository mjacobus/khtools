# frozen_string_literal: true

module Finance
  # Meeting-day nudge, one message per S-24 whose cash is still held, mentioning who has it so
  # Telegram notifies them. The message carries the cash buttons and becomes the one they update,
  # so older messages lost up the chat no longer matter.
  class CashReminders
    def initialize(account:, telegram:)
      @account = account
      @telegram = telegram
    end

    def remind(today: Date.current)
      pending = @account.finance_documents.cash_pending.where(document_date: ...today)
        .order(:document_date).select(&:cash_owed?)
      pending.each do |document|
        id = @telegram.send_message(chat_id: @account.finance_telegram_chat_id, html: true,
                                    text: text(document),
                                    buttons: Messages.cash_buttons(document))
        document.update!(cash_message_id: id)
      end
    end

    private

    def text(document)
      ["⏰ #{holder(document)}, dinheiro a entregar #{receivers}",
       CGI.escapeHTML(Messages.cash(document)), link(document)].compact.join("\n")
    end

    def link(document)
      if document.drive_url
        %(<a href="#{CGI.escapeHTML(document.drive_url)}">📄 Ver o S-24</a>)
      end
    end

    def receivers
      members = @account.finance_cash_receivers
      if members.any?
        names = members.map { |member| mention(member.telegram_id, member.display_name) }
        "a #{names.join(' ou ')}"
      else
        'ao servo de contas'
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
