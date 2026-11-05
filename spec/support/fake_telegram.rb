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

  def send_message(chat_id:, text:, reply_to: nil, buttons: nil, force_reply: false)
    @sent << { chat_id:, text:, reply_to:, buttons:, force_reply: }
    @next_id += 1
  end

  def edit_message(chat_id:, message_id:, text:, buttons: nil)
    @edits << { chat_id:, message_id:, text:, buttons: }
  end

  def answer_callback(id:, text: nil)
    @answers << { id:, text: }
  end

  def download(file_id:)
    files.fetch(file_id)
  end
end
