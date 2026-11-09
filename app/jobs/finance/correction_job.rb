# frozen_string_literal: true

module Finance
  # A correction said in plain words, typed or in a voice message: transcribed and understood
  # by Finance::CorrectionAssistant, then applied as if typed in the fields format.
  class CorrectionJob < ApplicationJob
    def perform(document_id, message)
      @document = Db::FinanceDocument.find(document_id)
      @message = message
      said = message['text'] || assistant.transcribe(audio:)
      fields = assistant.correction(text: said, document: @document)
      heard = message['text'] ? said : "🎤 #{said}"
      intake.correct(@document, message.merge('text' => fields), heard: "#{heard} → #{fields}")
    rescue Correction::Error => exception
      intake.reply(message, exception.message)
    end

    private

    delegate :account, to: :@document

    def intake
      Intake.new(account:)
    end

    def assistant
      @assistant ||= CorrectionAssistant.new(api_key: account.ai_api_key)
    end

    def audio
      file = @message['voice'] || @message['audio']
      Telegram::Client.new(token: account.finance_telegram_bot_token)
        .download(file_id: file['file_id'])
    end
  end
end
