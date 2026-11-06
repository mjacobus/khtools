# frozen_string_literal: true

module Finance
  # Handles one Telegram update for the finance bot of an account.
  class Intake # rubocop:disable Metrics/ClassLength -- one update type per small method
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
      if document
        correct(document, message)
      else
        file_of(message)&.then { |file| receive(message, file) }
      end
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
      if document.nil?
        {}
      elsif confirmer?(query)
        { text: send(action, document, query) }
      else
        { text: Messages::NOT_A_CONFIRMER }
      end
    end

    def confirm(document, query)
      if document.state == 'suggested' && document.competence.blank?
        Messages::NEEDS_MONTH
      elsif document.claim(from: 'suggested', state: 'confirmed', confirmed_at: Time.current,
                           confirmed_by: query.dig('from', 'first_name'))
        edit_bot_message(document, Messages::ARCHIVING)
        ArchiveJob.perform_later(document.id)
        nil
      else
        Messages::ALREADY_HANDLED
      end
    end

    def discard(document, _query)
      if document.claim(from: 'suggested', state: 'discarded')
        edit_bot_message(document, Messages::DISCARDED)
        nil
      else
        Messages::ALREADY_HANDLED
      end
    end

    def edit(document, _query)
      if document.state == 'suggested'
        prompt_id = telegram.send_message(chat_id: document.telegram_chat_id,
                                          text: Messages.edit_prompt,
                                          reply_to: document.bot_message_id, force_reply: true)
        document.update!(edit_prompt_message_id: prompt_id)
        nil
      else
        Messages::ALREADY_HANDLED
      end
    end

    def correct(document, message)
      if confirmer?(message) && document.state == 'suggested'
        Correction.apply(document:, text: message['text'])
        document.save!
        text, buttons = Messages.suggestion(document:)
        telegram.edit_message(chat_id: document.telegram_chat_id,
                              message_id: document.bot_message_id, text:, buttons:)
      end
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
