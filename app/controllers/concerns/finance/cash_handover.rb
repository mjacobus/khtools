# frozen_string_literal: true

module Finance
  # The treasurer got the cash of an S-24: the same as "Recebi" in the group (an action of
  # DocumentsController, so the same access covers it).
  module CashHandover
    def cash_received
      document = documents.where(kind: 's24').find(params[:id])
      document.update!(cash_received_at: Time.current, cash_received_by: current_user.name)
      update_cash_message(document)
      redirect_to finance_documents_path(month: document.competence)
    end

    private

    def update_cash_message(document)
      if document.cash_message_id
        Telegram::Client.new(token: current_account.finance_telegram_bot_token).edit_message(
          chat_id: document.telegram_chat_id, message_id: document.cash_message_id,
          text: Messages.cash(document), buttons: nil
        )
      end
    end
  end
end
