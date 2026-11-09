# frozen_string_literal: true

module Finance
  # Handles one Telegram update for the finance bot of an account.
  class Intake # rubocop:disable Metrics/ClassLength -- one update type per small method
    def initialize(account:,
                   telegram: Telegram::Client.new(token: account.finance_telegram_bot_token))
      @account = account
      @telegram = telegram
    end

    def handle(update:)
      update = update.to_h.deep_stringify_keys
      if update['callback_query']
        callback(update['callback_query'])
      elsif update['message'] && update.dig('message', 'chat',
                                            'id').to_s == @account.finance_telegram_chat_id.to_s
        group_message(update['message'])
      end
      retry_stuck
    end

    # +heard+ is what was said in plain words, kept in the history next to the fields.
    def correct(document, message, heard: nil)
      if !editor?(document, message)
        reply(message, Messages::NOT_AN_EDITOR)
      elsif document.state == 'suggested'
        apply_correction(document, message, heard)
        show_suggestion(document)
        reply(message, Messages::CORRECTED)
      end
    rescue Correction::Error => exception
      reply(message, exception.message)
    end

    def reply(message, text)
      telegram.send_message(chat_id: message.dig('chat', 'id'), text:,
                            reply_to: message['message_id'])
    end

    private

    def group_message(message)
      if message['migrate_to_chat_id']
        # the group became a supergroup, which has a new id; anything else sent there is ignored
        @account.update!(finance_telegram_chat_id: message['migrate_to_chat_id'].to_s)
      else
        remember(message)
        message(message)
      end
    end

    attr_reader :account, :telegram

    def message(message)
      prompt_id = message.dig('reply_to_message', 'message_id')
      document = prompt_id && documents.find_by(edit_prompt_message_id: prompt_id)
      if document
        correction(document, message)
      else
        file_of(message)&.then { |file| receive(message, file) }
      end
    end

    # The fields format is applied right away; anything else is understood by the assistant,
    # when there is an OpenAI key.
    def correction(document, message)
      plain_words = !fields_format?(message) && editor?(document, message)
      if plain_words && account.ai_api_key.present?
        CorrectionJob.perform_later(document.id, message)
        reply(message, Messages::LISTENING)
      elsif plain_words && !message['text']
        reply(message, Messages::NEEDS_AI)
      else
        correct(document, message)
      end
    end

    def fields_format?(message)
      first_word = message['text'].to_s.split.first.to_s
      Correction::KEYS.include?(Correction.normalize(first_word))
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
      sender = { sent_by_telegram_id: message.dig('from', 'id'), sent_by_name: name(message) }
      document = documents.create_with(file.merge(sender)).find_or_create_by!(
        telegram_chat_id: message.dig('chat', 'id'), telegram_message_id: message['message_id']
      )
      SuggestJob.perform_later(document.id) if document.previously_new_record?
    rescue ActiveRecord::RecordNotUnique
      nil # the same update arrived twice at the same time; the first one wins
    end

    def callback(query)
      action, id = query['data'].to_s
        .match(/\Afin:(confirm|edit|discard|cash_holder|cash_received|cash_pix):(\d+)\z/)&.captures
      document = id && documents.find_by(id:)
      telegram.answer_callback(id: query['id'], **callback_answer(action, document, query))
    end

    def callback_answer(action, document, query)
      if document.nil?
        {}
      elsif allowed?(action, document, query)
        { text: send(action, document, query) }
      else
        { text: refusal(action) }
      end
    end

    # Anyone can say they have the cash; whoever sent the file can correct it; only who takes
    # care of the accounts (if anyone has that role) says the cash arrived.
    def allowed?(action, document, query)
      case action
      when 'cash_holder' then true
      when 'edit' then editor?(document, query)
      when 'cash_received' then receiver?(query)
      else confirmer?(query)
      end
    end

    def refusal(action)
      case action
      when 'edit' then Messages::NOT_AN_EDITOR
      when 'cash_received'
        if account.finance_cash_receivers.exists?
          Messages::NOT_A_CASH_RECEIVER
        else
          Messages::NOT_A_CONFIRMER
        end
      else Messages::NOT_A_CONFIRMER
      end
    end

    def receiver?(query)
      receivers = account.finance_cash_receivers
      if receivers.exists?
        receivers.exists?(telegram_id: query.dig('from', 'id'))
      else
        confirmer?(query)
      end
    end

    def editor?(document, payload)
      confirmer?(payload) || payload.dig('from', 'id') == document.sent_by_telegram_id
    end

    def confirm(document, query)
      if document.state == 'suggested' && document.competence.blank?
        Messages::NEEDS_MONTH
      elsif document.claim(from: 'suggested', state: 'confirmed', **confirmation(query))
        edit_bot_message(document, Messages::ARCHIVING)
        ArchiveJob.perform_later(document.id)
        nil
      else
        Messages::ALREADY_HANDLED
      end
    end

    def confirmation(query)
      { confirmed_at: Time.current, confirmed_by: name(query),
        confirmed_by_telegram_id: query.dig('from', 'id') }
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

    def show_suggestion(document)
      text, buttons = Messages.suggestion(document:)
      telegram.edit_message(chat_id: document.telegram_chat_id,
                            message_id: document.bot_message_id, text:, buttons:)
    end

    def apply_correction(document, message, heard)
      Correction.apply(document:, text: message['text'])
      document.record_correction(by_telegram_id: message.dig('from', 'id'),
                                 by_name: name(message), text: heard || message['text'])
      document.save!
    end

    def cash_holder(document, query)
      if document.cash_received_at
        Messages::ALREADY_HANDLED
      elsif document.cash_holder_telegram_id == query.dig('from', 'id')
        Messages::ALREADY_WITH_YOU
      else
        cash_update(document, cash_holder_telegram_id: query.dig('from', 'id'),
                              cash_holder_name: name(query))
      end
    end

    def cash_received(document, query)
      if document.cash_received_at
        Messages::ALREADY_HANDLED
      else
        cash_update(document, cash_received_at: Time.current,
                              cash_received_by: name(query))
      end
    end

    def cash_pix(document, query)
      if document.cash_pix_at
        Messages::ALREADY_HANDLED
      else
        cash_update(document, cash_pix_at: Time.current,
                              cash_pix_by: name(query))
      end
    end

    def cash_update(document, changes)
      document.update!(changes)
      telegram.edit_message(chat_id: document.telegram_chat_id,
                            message_id: document.cash_message_id,
                            text: Messages.cash(document),
                            buttons: Messages.cash_buttons(document))
      nil
    end

    def edit_bot_message(document, text)
      telegram.edit_message(chat_id: document.telegram_chat_id,
                            message_id: document.bot_message_id, text:)
    end

    def remember(payload)
      telegram_id = payload.dig('from', 'id')
      if telegram_id
        Db::FinanceTelegramMember.remember(account:, telegram_id:, name: telegram_name(payload))
      end
    end

    # The linked publisher's name when there is one: the bot calls people by it.
    def name(payload)
      member = account.finance_telegram_members.find_by(telegram_id: payload.dig('from', 'id'))
      member&.publisher&.name || telegram_name(payload)
    end

    def telegram_name(payload)
      payload['from'].to_h.values_at('first_name', 'last_name').compact.join(' ').presence
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
