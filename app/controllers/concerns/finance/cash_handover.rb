# frozen_string_literal: true

module Finance
  # The accounts servant or a helper got the cash of an S-24, or its Pix was made, as with the
  # group buttons (actions of DocumentsController, so the same access covers them).
  module CashHandover
    extend ActiveSupport::Concern

    included { helper_method :cash_receiver? }

    def cash_received
      document = documents.where(kind: 's24').find(params[:id])
      if cash_receiver?
        document.update!(cash_received_at: Time.current, cash_received_by: current_user.name)
        update_cash_message(document)
        redirect_to finance_documents_path(month: document.competence)
      else
        head :forbidden
      end
    end

    def cash_pix
      document = documents.where(kind: 's24').find(params[:id])
      document.update!(cash_pix_at: Time.current, cash_pix_by: current_user.name)
      update_cash_message(document)
      redirect_to finance_documents_path(month: document.competence)
    end

    private

    # The accounts servant or a helper, when their publisher is this user. With nobody in those
    # roles linked to a user yet, anyone with access to the documents can.
    def cash_receiver?
      user_ids = current_account.finance_cash_receivers.includes(:publisher)
        .filter_map { |member| member.publisher&.user_id }
      user_ids.empty? || user_ids.include?(current_user.id)
    end

    def update_cash_message(document)
      if document.cash_message_id
        Telegram::Client.new(token: current_account.finance_telegram_bot_token).edit_message(
          chat_id: document.telegram_chat_id, message_id: document.cash_message_id,
          text: Messages.cash(document), buttons: Messages.cash_buttons(document)
        )
      end
    end
  end
end
