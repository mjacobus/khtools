# frozen_string_literal: true

module Finance
  # The file of a document not in Drive yet (waiting for confirmation, archiving or failed): the
  # copy kept until archived, or downloaded again from Telegram if a deploy wiped it. Telegram's
  # own file URL can't be linked: it carries the bot token.
  module DocumentFiles
    def file
      document = documents.find(params[:id])
      send_file local_file(document), type: document.pdf? ? 'application/pdf' : 'image/jpeg',
                                      disposition: 'inline', filename: document.drive_name
    end

    private

    def local_file(document)
      unless File.exist?(document.local_path)
        telegram = Telegram::Client.new(token: current_account.finance_telegram_bot_token)
        document.store_local_copy(telegram.download(file_id: document.telegram_file_id))
      end
      document.local_path
    end
  end
end
