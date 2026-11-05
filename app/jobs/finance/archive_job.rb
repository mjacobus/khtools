# frozen_string_literal: true

module Finance
  # Uploads a confirmed document to Contas Central/Arquivo Corrente/<competence>/.
  # On failure the document stays confirmed and Intake retries it later.
  class ArchiveJob < ApplicationJob
    CURRENT_FOLDER = 'Arquivo Corrente'

    def perform(document_id)
      @document = Db::FinanceDocument.find(document_id)
      return unless @document.state == 'confirmed' && claim

      archive
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
      folder = month_folder
      result = drive.upload(path: upload_path, name: free_name(folder), parent_id: folder,
                            mime_type:, description:, app_properties:)
      @document.update!(state: 'archived', drive_file_id: result[:id],
                        drive_url: result[:web_view_link], last_error: nil)
      FileUtils.rm_f(@document.local_path)
      edit_bot_message(Messages.archived(document: @document))
    end

    def month_folder
      current = drive.find_folder(name: CURRENT_FOLDER,
                                  parent_id: account.finance_drive_root_folder_id)
      raise "Pasta \"#{CURRENT_FOLDER}\" não encontrada na raiz configurada" unless current

      drive.find_folder(name: @document.competence, parent_id: current) ||
        drive.create_folder(name: @document.competence, parent_id: current)
    end

    def free_name(folder)
      name = Naming.filename(document: @document)
      ext = File.extname(name)
      candidates = [name] + (2..).lazy.map do |n|
                              "#{File.basename(name, ext)} (#{n})#{ext}"
                            end.first(98)
      candidates.find { |candidate| !drive.find_file(name: candidate, parent_id: folder) } ||
        raise("No free name for #{name}")
    end

    # Decryptable statements go up without the password; ones we couldn't open go as-is.
    def upload_path
      path = local_file
      return path unless @document.flagged?(:decryptable)

      Pdf.decrypt(path:, password: account.finance_statement_password,
                  output: "#{path}.decrypted.pdf")
    end

    def local_file
      path = @document.local_path
      return path.to_s if File.exist?(path)

      @document.store_local_copy(telegram.download(file_id: @document.telegram_file_id))
      path.to_s
    end

    def mime_type
      @document.mime_type.presence || (@document.pdf? ? 'application/pdf' : 'image/jpeg')
    end

    def description
      [
        Messages.s24_split(@document),
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
      return unless @document

      @document.update!(last_error: "#{error.class}: #{error.message}")
      edit_bot_message(Messages::ARCHIVE_FAILED)
    rescue StandardError => exception
      ErrorHandler.new.notify_error(exception)
    end

    def edit_bot_message(text)
      telegram.edit_message(chat_id: @document.telegram_chat_id,
                            message_id: @document.bot_message_id, text:)
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
