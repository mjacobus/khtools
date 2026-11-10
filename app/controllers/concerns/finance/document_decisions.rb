# frozen_string_literal: true

module Finance
  # Confirm or discard a suggestion from the documents page, as the Telegram buttons do (the
  # bot message is updated too). Whoever has access to the page may decide.
  module DocumentDecisions
    def confirm
      document = documents.find(params[:id])
      if document.competence.blank?
        back_to(document, error: 'Falta o mês: corrija o documento antes de confirmar.')
      elsif claim_confirmation(document)
        ArchiveJob.perform_later(document.id)
        back_to(document, notice: Messages::ARCHIVING)
      else
        back_to(document, error: Messages::ALREADY_HANDLED)
      end
    end

    def discard
      document = documents.find(params[:id])
      if document.claim(from: 'suggested', state: 'discarded')
        tell_the_group(document, Messages::DISCARDED)
        back_to(document, notice: Messages::DISCARDED)
      else
        back_to(document, error: Messages::ALREADY_HANDLED)
      end
    end

    private

    def claim_confirmation(document)
      claimed = document.claim(from: 'suggested', state: 'confirmed',
                               confirmed_at: Time.current, confirmed_by: current_user.name)
      if claimed
        tell_the_group(document, Messages::ARCHIVING)
      end
      claimed
    end

    def back_to(document, **flash)
      redirect_to finance_documents_path(month: document.competence.presence), flash:
    end

    # The decision stands even if Telegram is down; the suggestion message just stays as it was.
    def tell_the_group(document, text)
      if document.bot_message_id
        Telegram::Client.new(token: current_account.finance_telegram_bot_token)
          .edit_message(chat_id: document.telegram_chat_id, message_id: document.bot_message_id,
                        text:)
      end
    rescue Telegram::Client::Error => exception
      ErrorHandler.new.notify_error(exception)
    end
  end
end
