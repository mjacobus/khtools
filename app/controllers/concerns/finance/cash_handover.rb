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
      document.update!(cash_pix_at: Time.current, cash_pix_by: current_user.name,
                       cash_pix_by_telegram_id: own_telegram_id)
      update_cash_message(document)
      redirect_to finance_documents_path(month: document.competence)
    end

    private

    # The accounts servant, a helper or who is responsible for the accounts, when their publisher
    # is this user. With no servant or helper linked to a user yet, anyone with access can.
    def cash_receiver?
      user_ids(current_account.finance_cash_receivers).empty? ||
        user_ids(current_account.finance_cash_checkers).include?(current_user.id)
    end

    # The group member linked to this user, if any.
    def own_telegram_id
      current_account.finance_telegram_members.joins(:publisher)
        .find_by(publishers: { user_id: current_user.id })&.telegram_id
    end

    def user_ids(members)
      members.includes(:publisher).filter_map { |member| member.publisher&.user_id }
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
