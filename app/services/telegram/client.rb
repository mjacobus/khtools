# frozen_string_literal: true

module Telegram
  # Minimal Telegram Bot API client: only the calls the finance bot uses.
  class Client
    class Error < StandardError; end

    BASE_URL = 'https://api.telegram.org'

    def initialize(token:)
      @token = token
    end

    def get_updates(offset:, timeout: 30)
      call('getUpdates', offset:, timeout:, allowed_updates: %w[message callback_query])
    end

    def chat_administrators(chat_id:)
      users = call('getChatAdministrators', chat_id:).pluck('user').reject { |user| user['is_bot'] }
      users.map do |user|
        { id: user['id'], name: user.values_at('first_name', 'last_name').compact.join(' ') }
      end
    end

    def download(file_id:)
      path = call('getFile', file_id:).fetch('file_path')
      response = Net::HTTP.get_response(URI("#{BASE_URL}/file/bot#{@token}/#{path}"))
      unless response.code.to_s.start_with?('2')
        raise Error,
              "download failed with HTTP #{response.code}"
      end

      response.body
    end

    def send_message(chat_id:, text:, reply_to: nil, buttons: nil, force_reply: false, html: false) # rubocop:disable Metrics/ParameterLists
      params = { chat_id:, text:, reply_markup: markup(buttons, force_reply),
                 parse_mode: parse_mode(html) }
      if reply_to
        params[:reply_parameters] =
          { message_id: reply_to, allow_sending_without_reply: true }
      end
      call('sendMessage', **params.compact).fetch('message_id')
    end

    def edit_message(chat_id:, message_id:, text:, buttons: nil, html: false)
      params = { chat_id:, message_id:, text:, reply_markup: markup(buttons, false),
                 parse_mode: parse_mode(html) }
      call('editMessageText', **params.compact)
    rescue Error => exception
      # Telegram refuses an edit to the same text and buttons; that is done already.
      unless exception.message.include?('message is not modified')
        raise
      end
    end

    def answer_callback(id:, text: nil)
      call('answerCallbackQuery', **{ callback_query_id: id, text: }.compact)
    end

    def set_webhook(url:, secret:)
      call('setWebhook', url:, secret_token: secret, allowed_updates: %w[message callback_query])
    end

    def delete_webhook
      call('deleteWebhook')
    end

    private

    def markup(buttons, force_reply)
      if force_reply
        { force_reply: true }
      elsif buttons
        { inline_keyboard: buttons.map { |row| keyboard_row(row) } }
      else
        { inline_keyboard: [] } # an empty keyboard removes the buttons when editing
      end
    end

    def parse_mode(html)
      if html
        'HTML'
      end
    end

    def keyboard_row(row)
      row.map { |text, data| { text:, callback_data: data } }
    end

    def call(method, **params)
      response = Net::HTTP.post(URI("#{BASE_URL}/bot#{@token}/#{method}"), params.to_json,
                                'Content-Type' => 'application/json')
      body = JSON.parse(response.body)
      unless body['ok']
        raise Error, "#{method}: #{body['description']}"
      end

      body['result']
    end
  end
end
