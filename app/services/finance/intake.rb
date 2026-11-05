# frozen_string_literal: true

module Finance
  # Handles one Telegram update for the finance bot of an account.
  class Intake
    def initialize(account:,
                   telegram: Telegram::Client.new(token: account.finance_telegram_bot_token))
      @account = account
      @telegram = telegram
    end

    def call(update:)
      update = update.to_h.deep_stringify_keys
      if update['callback_query']
        callback(update['callback_query'])
      elsif update['message'] && update.dig('message', 'chat',
                                            'id').to_s == @account.finance_telegram_chat_id.to_s
        message(update['message'])
      end
      retry_stuck
    end

    private

    attr_reader :account, :telegram

    def message(message)
      prompt_id = message.dig('reply_to_message', 'message_id')
      document = prompt_id && documents.find_by(edit_prompt_message_id: prompt_id)
      return correct(document, message) if document

      file_of(message)&.then { |file| receive(message, file) }
    end

    def file_of(message)
      if message['photo'].present?
        { telegram_file_id: message['photo'].max_by { |size| size['file_size'].to_i }['file_id'],
          mime_type: 'image/jpeg' }
      elsif (doc = message['document'])
        { telegram_file_id: doc['file_id'], original_filename: doc['file_name'],
          mime_type: doc['mime_type'] }
      end
    end

    def receive(message, file)
      document = documents.create_with(file).find_or_create_by!(
        telegram_chat_id: message.dig('chat', 'id'), telegram_message_id: message['message_id']
      )
      SuggestJob.perform_later(document.id) if document.previously_new_record?
    rescue ActiveRecord::RecordNotUnique
      nil # the same update arrived twice at the same time; the first one wins
    end

    def callback(query)
      action, id = query['data'].to_s.match(/\Afin:(confirm|edit|discard):(\d+)\z/)&.captures
      document = id && documents.find_by(id:)
      telegram.answer_callback(id: query['id'], **callback_answer(action, document, query))
    end

    def callback_answer(action, document, query)
      return {} unless document
      return { text: Messages::NOT_A_CONFIRMER } unless confirmer?(query)

      { text: send(action, document, query) }
    end

    def confirm(document, query)
      return Messages::ALREADY_HANDLED unless document.state == 'suggested'
      return Messages::NEEDS_MONTH if document.competence.blank?

      document.update!(state: 'confirmed', confirmed_by: query.dig('from', 'first_name'),
                       confirmed_at: Time.current)
      ArchiveJob.perform_later(document.id)
      edit_bot_message(document, Messages::ARCHIVING)
      nil
    end

    def discard(document, _query)
      return Messages::ALREADY_HANDLED unless document.state == 'suggested'

      document.update!(state: 'discarded')
      edit_bot_message(document, Messages::DISCARDED)
      nil
    end

    def edit(document, _query)
      return Messages::ALREADY_HANDLED unless document.state == 'suggested'

      prompt_id = telegram.send_message(chat_id: document.telegram_chat_id,
                                        text: Messages.edit_prompt,
                                        reply_to: document.bot_message_id, force_reply: true)
      document.update!(edit_prompt_message_id: prompt_id)
      nil
    end

    def correct(document, message)
      return unless confirmer?(message) && document.state == 'suggested'

      Correction.apply(document:, text: message['text'])
      document.save!
      text, buttons = Messages.suggestion(document:)
      telegram.edit_message(chat_id: document.telegram_chat_id,
                            message_id: document.bot_message_id, text:, buttons:)
    rescue Correction::Error => exception
      telegram.send_message(chat_id: document.telegram_chat_id, text: exception.message,
                            reply_to: message['message_id'])
    end

    def edit_bot_message(document, text)
      telegram.edit_message(chat_id: document.telegram_chat_id,
                            message_id: document.bot_message_id, text:)
    end

    def confirmer?(payload)
      account.finance_confirmer?(payload.dig('from', 'id'))
    end

    # ponytail: piggyback retry on traffic; add a scheduler if groups go quiet for long
    def retry_stuck
      documents.stuck.find_each do |document|
        document.touch # rubocop:disable Rails/SkipsModelValidations -- bump updated_at so a stuck doc is not re-enqueued on every update
        (document.state == 'received' ? SuggestJob : ArchiveJob).perform_later(document.id)
      end
    end

    def documents
      account.finance_documents
    end
  end
end
