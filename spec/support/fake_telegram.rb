# frozen_string_literal: true

# Records what the finance bot would send to Telegram.
class FakeTelegram
  attr_reader :sent, :edits, :answers
  attr_accessor :files

  def initialize
    @sent = []
    @edits = []
    @answers = []
    @files = {}
    @next_id = 500
  end

  def send_message(chat_id:, text:, reply_to: nil, buttons: nil, force_reply: false, html: false) # rubocop:disable Metrics/ParameterLists
    @sent << { chat_id:, text:, reply_to:, buttons:, force_reply:, html: }
    @next_id += 1
  end

  def edit_message(chat_id:, message_id:, text:, buttons: nil, html: false)
    @edits << { chat_id:, message_id:, text:, buttons:, html: }
  end

  def answer_callback(id:, text: nil)
    @answers << { id:, text: }
  end

  def download(file_id:)
    files.fetch(file_id)
  end
end
