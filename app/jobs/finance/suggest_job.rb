# frozen_string_literal: true

module Finance
  # Downloads a received document, reads it and replies in the group with a suggestion.
  class SuggestJob < ApplicationJob # rubocop:disable Metrics/ClassLength -- download, read, reply, give up
    def perform(document_id)
      @document = Db::FinanceDocument.find(document_id)
      if @document.state == 'received'
        suggest
      end
    rescue StandardError => exception
      handle_failure(exception)
    end

    private

    delegate :account, to: :@document

    def telegram
      @telegram ||= Telegram::Client.new(token: account.finance_telegram_bot_token)
    end

    def download
      telegram.download(file_id: @document.telegram_file_id).tap do |bytes|
        @document.store_local_copy(bytes)
      end
    end

    def suggest
      bytes = download
      # saved now so a job running in parallel for the same bytes sees it
      @document.update!(sha256: Digest::SHA256.hexdigest(bytes))
      original = @document.earlier_duplicate
      if original
        reject_duplicate(original)
      else
        @document.pdf? ? read_pdf : read_photo(bytes)
        reply
      end
    end

    def reject_duplicate(original)
      answer(Messages.duplicate(original:))
      @document.update!(state: 'discarded')
      FileUtils.rm_f(@document.local_path)
    end

    def read_photo(bytes)
      result = read_receipt(bytes)
      if result.nil? # AI down: ask a human for the values
        @document.kind = 's24'
      elsif result.is_s24
        assign_receipt(result)
      else
        @document.kind = 'unknown'
      end
    end

    def assign_receipt(result)
      @document.assign_attributes(
        kind: 's24', value_source: 'ai', document_date: parse_date(result.date),
        congregation_cents: result.congregation_cents, worldwide_cents: result.worldwide_cents,
        amount_cents: result.congregation_cents.to_i + result.worldwide_cents.to_i
      )
      @document.assign_competence
    end

    def read_receipt(bytes)
      if account.anthropic_api_key.present?
        ReceiptReader.new(api_key: account.anthropic_api_key)
          .call(image_bytes: bytes, mime_type: @document.mime_type || 'image/jpeg')
      end
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
      if password.blank?
        raise Pdf::PasswordError, 'no password'
      end

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

    # ponytail: age-based give-up instead of an attempts counter; retries come from Intake's
    # stuck sweep. Files over Telegram's 20 MB bot limit never download, so give up at once.
    GIVE_UP_AFTER = 1.hour

    def handle_failure(error)
      ErrorHandler.new.notify_error(error)
      unless @document
        return
      end

      @document.update!(last_error: "#{error.class}: #{error.message}")
      too_big = error.message.match?(/file is too big/i)
      give_up if too_big || @document.created_at < GIVE_UP_AFTER.ago
    end

    def give_up
      @document.update!(state: 'failed')
      FileUtils.rm_f(@document.local_path)
      answer(Messages::UNREADABLE)
    end

    def answer(text)
      telegram.send_message(chat_id: @document.telegram_chat_id, text:,
                            reply_to: @document.telegram_message_id)
    end

    def parse_date(text)
      Date.iso8601(text.to_s)
    rescue Date::Error
      nil
    end
  end
end
