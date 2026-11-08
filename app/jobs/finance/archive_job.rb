# frozen_string_literal: true

module Finance
  # Uploads a confirmed document to Contas Central/Arquivo Corrente/<competence>/.
  # On failure the document stays confirmed and Intake retries it later.
  class ArchiveJob < ApplicationJob # rubocop:disable Metrics/ClassLength -- upload or replace, metadata, failure
    def perform(document_id)
      @document = Db::FinanceDocument.find(document_id)
      if @document.state == 'confirmed' && claim
        archive
      end
    rescue StandardError => exception
      fail_with(exception)
    ensure
      FileUtils.rm_f("#{@document.local_path}.decrypted.pdf") if @document
    end

    private

    def account
      @document.account
    end

    # Two jobs for the same document (retry sweep, double enqueue): only the one that bumps
    # updated_at from the value it read gets to upload.
    def claim
      Db::FinanceDocument.where(id: @document.id, state: 'confirmed',
                                updated_at: @document.updated_at)
        .update_all(updated_at: Time.current) == 1 # rubocop:disable Rails/SkipsModelValidations
    end

    def archive
      previous = @document.replaced_document
      result = (previous && replace(previous)) || upload
      @document.update!(state: 'archived', drive_file_id: result[:id],
                        drive_url: result[:web_view_link], last_error: nil)
      FileUtils.rm_f(@document.local_path)
      replaced = result[:id] == previous&.drive_file_id
      edit_bot_message(Messages.archived(document: @document, replaced:), html: true)
      start_cash_handover
    end

    # The cash of a meeting stays with someone until the treasurer gets it; the first guess is
    # whoever printed their name on the S-24, else whoever sent it. "Está comigo" corrects it.
    def start_cash_handover
      if cash_to_track?
        @document.assign_attributes(cash_holder)
        @document.update!(cash_message_id: telegram.send_message(
          chat_id: @document.telegram_chat_id, text: Messages.cash(@document),
          buttons: Messages.cash_buttons(@document)
        ))
      end
    rescue StandardError => exception
      ErrorHandler.new.notify_error(exception) # the file is archived; only the cash note failed
    end

    def cash_to_track?
      @document.kind == 's24' && @document.cash_holder_name.nil? &&
        (@document.collector_name || @document.sent_by_name).present?
    end

    def cash_holder
      name = @document.collector_name
      if name.blank?
        { cash_holder_telegram_id: @document.sent_by_telegram_id,
          cash_holder_name: @document.sent_by_name }
      else
        member = Db::FinanceTelegramMember.matching(account: @document.account, name:)
        { cash_holder_telegram_id: member&.telegram_id,
          cash_holder_name: member&.display_name || name.titleize }
      end
    end

    def upload
      folder = month_folder
      drive.upload(path: upload_path, name: free_name(folder), parent_id: folder,
                   mime_type:, description:, app_properties:)
    end

    # nil when the old file was deleted from Drive: then it goes up as a new file.
    def replace(previous)
      drive.update_file(id: previous.drive_file_id, path: upload_path, mime_type:, description:,
                        app_properties:)
    rescue GoogleDrive::Client::Error => exception
      unless exception.message.include?('HTTP 404')
        raise
      end
    end

    def month_folder
      MonthFolder.new(account:, drive:).find_or_create(competence: @document.competence)
    end

    def free_name(folder)
      name = Naming.filename(document: @document)
      ext = File.extname(name)
      candidates = [name] + (2..99).map { |n| "#{File.basename(name, ext)} (#{n})#{ext}" }
      candidates.find { |candidate| !drive.find_file(name: candidate, parent_id: folder) } ||
        raise("No free name for #{name}")
    end

    # Decryptable statements go up without the password; ones we couldn't open go as-is.
    def upload_path
      path = local_file
      if @document.flagged?(:decryptable)
        Pdf.decrypt(path:, password: account.finance_statement_password,
                    output: "#{path}.decrypted.pdf")
      else
        path
      end
    end

    def local_file
      path = @document.local_path
      unless File.exist?(path)
        @document.store_local_copy(telegram.download(file_id: @document.telegram_file_id))
      end
      path.to_s
    end

    def mime_type
      @document.mime_type.presence || (@document.pdf? ? 'application/pdf' : 'image/jpeg')
    end

    def description
      [
        Messages.s24_split(@document),
        Messages.s24_total_mismatch(@document),
        "competência #{@document.competence}",
        @document.confirmed_by && "confirmado por #{@document.confirmed_by} em " \
                                  "#{@document.confirmed_at&.strftime('%d/%m/%Y')}"
      ].compact.join(' · ')
    end

    def app_properties
      @document.slice(:kind, :competence, :amount_cents, :congregation_cents, :worldwide_cents,
                      :confirmed_by)
        .symbolize_keys.merge(khtools_id: @document.id)
    end

    def fail_with(error)
      ErrorHandler.new.notify_error(error)
      if @document
        @document.update!(last_error: "#{error.class}: #{error.message}")
        edit_bot_message(Messages::ARCHIVE_FAILED)
      end
    rescue StandardError => exception
      ErrorHandler.new.notify_error(exception)
    end

    def edit_bot_message(text, html: false)
      telegram.edit_message(chat_id: @document.telegram_chat_id,
                            message_id: @document.bot_message_id, text:, html:)
    end

    def drive
      @drive ||= GoogleDrive::Client.new(
        refresh_token: account.finance_google_refresh_token,
        client_id: Rails.application.credentials.dig(:oauth, :google, :key),
        client_secret: Rails.application.credentials.dig(:oauth, :google, :secret)
      )
    end

    def telegram
      @telegram ||= Telegram::Client.new(token: account.finance_telegram_bot_token)
    end
  end
end
