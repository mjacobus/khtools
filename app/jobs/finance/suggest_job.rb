# frozen_string_literal: true

module Finance
  # Downloads a received document, reads it and replies in the group with a suggestion.
  class SuggestJob < ApplicationJob
    def perform(document_id)
      @document = Db::FinanceDocument.find(document_id)
      return unless @document.state == 'received'

      bytes = download
      @document.sha256 = Digest::SHA256.hexdigest(bytes)
      return reject_duplicate(duplicate) if duplicate

      @document.pdf? ? read_pdf : read_photo(bytes)
      reply
    end

    private

    def account
      @document.account
    end

    def telegram
      @telegram ||= Telegram::Client.new(token: account.finance_telegram_bot_token)
    end

    def download
      telegram.download(file_id: @document.telegram_file_id).tap do |bytes|
        FileUtils.mkdir_p(File.dirname(@document.local_path))
        File.binwrite(@document.local_path, bytes)
      end
    end

    def duplicate
      @duplicate ||= account.finance_documents.where(sha256: @document.sha256)
        .where.not(id: @document.id).where.not(state: 'discarded').first
    end

    def reject_duplicate(original)
      telegram.send_message(chat_id: @document.telegram_chat_id,
                            text: Messages.duplicate(original:),
                            reply_to: @document.telegram_message_id)
      @document.update!(state: 'discarded')
      FileUtils.rm_f(@document.local_path)
    end

    def read_photo(bytes)
      result = read_receipt(bytes)
      return @document.kind = 's24' unless result # AI down: ask a human for the values
      return @document.kind = 'unknown' unless result.is_s24

      @document.assign_attributes(
        kind: 's24', value_source: 'ai', document_date: parse_date(result.date),
        congregation_cents: result.congregation_cents, worldwide_cents: result.worldwide_cents,
        amount_cents: result.congregation_cents.to_i + result.worldwide_cents.to_i
      )
      @document.assign_competence
    end

    def read_receipt(bytes)
      return if account.anthropic_api_key.blank?

      ReceiptReader.new(api_key: account.anthropic_api_key)
        .call(image_bytes: bytes, mime_type: @document.mime_type || 'image/jpeg')
    end

    def read_pdf
      result = Classifier.call(text: pdf_text, filename: @document.original_filename)
      @document.assign_attributes(result.to_h.except(:period))
      @document.value_source = 'rules' if [result.amount_cents, result.document_date,
                                           result.period].any?
      @document.assign_competence(period: result.period)
    rescue Pdf::PasswordError
      # ponytail: only bank statements come with a password
      @document.add_flag(:encrypted_original)
      @document.kind = 'statement'
    end

    # Owner-password PDFs (print/copy limits) open without a password; only files that
    # need a user password get the account's statement password.
    def pdf_text
      Pdf.text(path: @document.local_path.to_s)
    rescue Pdf::PasswordError
      unlocked_text
    rescue Pdf::Error
      ''
    end

    def unlocked_text
      password = account.finance_statement_password
      raise Pdf::PasswordError, 'no password' if password.blank?

      Pdf.text(path: @document.local_path.to_s, password:).tap { @document.add_flag(:decryptable) }
    rescue Pdf::PasswordError
      raise
    rescue Pdf::Error
      ''
    end

    def reply
      @document.state = 'suggested'
      text, buttons = Messages.suggestion(document: @document)
      @document.bot_message_id = telegram.send_message(chat_id: @document.telegram_chat_id,
                                                       text:, buttons:,
                                                       reply_to: @document.telegram_message_id)
      @document.save!
    end

    def parse_date(text)
      Date.iso8601(text.to_s)
    rescue Date::Error
      nil
    end
  end
end
