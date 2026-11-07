# frozen_string_literal: true

module Finance
  # Audited months that can leave Arquivo Corrente (S-27b par. 50), moved only on request
  # (actions of DocumentsController, so the same access covers them).
  module ArchiveMoves
    def archive
      @due_months = rotation.due_months
    end

    def move_to_archive
      rotation.move(month: params.require(:month))
      redirect_to archive_finance_documents_path,
                  notice: "#{params[:month]} foi para #{MonthFolder::PAST}"
    rescue GoogleDrive::Client::Error, ArgumentError => exception
      redirect_to archive_finance_documents_path, alert: exception.message
    end

    private

    def rotation
      ArchiveRotation.new(account: current_account, drive:)
    end
  end
end
